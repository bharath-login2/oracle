import 'package:flutter/material.dart';

import '../../models/projectdetails/installation_activity_model.dart';
import '../../models/projectdetails/unit_info_model.dart';
import '../../service/service.dart';

class UnitInfoDetailsPage extends StatefulWidget {
  final UnitInfoData unit;

  const UnitInfoDetailsPage({
    super.key,
    required this.unit,
  });

  @override
  State<UnitInfoDetailsPage> createState() => _UnitInfoDetailsPageState();
}

class _UnitInfoDetailsPageState extends State<UnitInfoDetailsPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);
  static const Color _pageBackground = Color(0xFFF3F5F8);

  List<ActivityItem> _activities = [];

  bool _isLoadingActivities = true;
  String? _activityErrorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadInstallationActivities();
  }

  // ============================================================
  // WHEN SELECTED UNIT CHANGES
  // ============================================================

  @override
  void didUpdateWidget(
    covariant UnitInfoDetailsPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.unit.unitId != widget.unit.unitId) {
      _loadInstallationActivities();
    }
  }

  // ============================================================
  // LOAD INSTALLATION ACTIVITIES
  // ============================================================

  Future<void> _loadInstallationActivities() async {
    if (!mounted) return;

    setState(() {
      _isLoadingActivities = true;
      _activityErrorMessage = null;
    });

    try {
      /*
     * Installation activities are fetched separately.
     *
     * The API receives:
     *
     * projectId -> selected unit project ID
     * unitId    -> selected unit database ID
     * methodId  -> selected unit installation method ID
     *
     * The activities are returned by the API for the
     * selected unit.
     *
     * No activity names or activity keys are hardcoded.
     */

      final response = await HttpService.getUnitActivityDetails(
          projectId: widget.unit.projectId,
          unitNo: widget.unit.unitId,
          methodId: widget.unit.methodId);

      if (!mounted) return;

      if (response != null) {
        setState(() {
          _activities = response.data;
          _isLoadingActivities = false;
          _activityErrorMessage = null;
        });
      } else {
        setState(() {
          _activities = [];
          _isLoadingActivities = false;
          _activityErrorMessage = 'Failed to load installation activities';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _activities = [];
        _isLoadingActivities = false;
        _activityErrorMessage = 'Failed to load installation activities';
      });
    }
  }

  // ============================================================
  // DISPLAY HELPER
  // ============================================================

  String _display(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value.trim().toLowerCase() == 'null') {
      return '--';
    }

    return value.trim();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(String? dateStr) {
    if (dateStr == null ||
        dateStr.trim().isEmpty ||
        dateStr.trim().toLowerCase() == 'null') {
      return '--';
    }

    final clean = dateStr.trim();

    // Already dd-MM-yyyy
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(clean)) {
      return clean;
    }

    // yyyy-MM-dd or ISO date
    final parsed = DateTime.tryParse(clean);

    if (parsed != null) {
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final year = parsed.year.toString();

      return '$day-$month-$year';
    }

    // Fallback for yyyy-MM-dd
    if (clean.contains('-')) {
      final parts = clean.split('-');

      if (parts.length >= 3 && parts[0].length == 4) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2].split(' ').first;

        return '${day.padLeft(2, '0')}-'
            '${month.padLeft(2, '0')}-'
            '$year';
      }
    }

    return clean;
  }

  // ============================================================
  // PERCENTAGE FORMAT
  // ============================================================

  String _formatPercentage(String value) {
    final percentage = double.tryParse(value) ?? 0;

    if (percentage == percentage.truncateToDouble()) {
      return '${percentage.toInt()}%';
    }

    return '${percentage.toStringAsFixed(1)}%';
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final unit = widget.unit;

    final unitNumber = _display(
      unit.unitName.isNotEmpty ? unit.unitName : unit.unitId,
    );

    final siteLiftNo = _display(
      unit.siteLiftName,
    );

    final machineNo = _display(
      unit.unitMachineNo,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14,
      ),
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.elevator_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit #$unitNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Site Lift No: $siteLiftNo  |  '
                  'Machine No: $machineNo',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _buildInfoRow(
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF718096),
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _display(value),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TWO COLUMN INFORMATION ROW
  // ============================================================

  Widget _buildTwoColumnRow(
    String label1,
    String? value1,
    String label2,
    String? value2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoRow(
            label1,
            value1,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _buildInfoRow(
            label2,
            value2,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus(
    String? status, {
    String? percentage,
  }) {
    final percentageValue = double.tryParse(
          percentage ?? '',
        ) ??
        0;

    final raw =
        percentageValue == 0 ? 'pending' : (status ?? '').trim().toLowerCase();

    Color background;
    Color foreground;
    String label;

    switch (raw) {
      case 'completed':
        background = const Color(0xFF16B8A6);
        foreground = Colors.white;
        label = 'Completed';
        break;

      case 'in_progress':
      case 'in progress':
        background = const Color(0xFF31558D);
        foreground = Colors.white;
        label = 'In Progress';
        break;

      case 'pending':
        background = const Color(0xFFF6A623);
        foreground = Colors.white;
        label = 'Pending';
        break;

      case 'on_hold':
      case 'on hold':
        background = const Color(0xFFFF5B43);
        foreground = Colors.white;
        label = 'On Hold';
        break;

      case 'not_applicable':
      case 'not applicable':
        background = const Color(0xFF4285F4);
        foreground = Colors.white;
        label = 'Not Applicable';
        break;

      case '':
        background = Colors.grey.shade200;
        foreground = Colors.grey.shade700;
        label = '--';
        break;

      default:
        background = Colors.grey;
        foreground = Colors.white;
        label = _display(status);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY PROGRESS
  // ============================================================

  Widget _buildProgress(
    ActivityItem activity,
  ) {
    final percentage = double.tryParse(activity.percentage) ?? 0;

    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE9EDF2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                _primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 35,
          child: Text(
            _formatPercentage(
              activity.percentage,
            ),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVITY CARD
  // ============================================================

  Widget _buildActivityCard(
    ActivityItem activity,
  ) {
    // Both activity name and activity key come directly from API.
    // No hardcoded activity names or activity keys.

    final activityName = _display(activity.activityName);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // ACTIVITY NAME + STATUS
          // ==================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comes directly from:
                    // json['activity_name']
                    Text(
                      activityName,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Comes directly from:
                    // json['activity_key']
                    //
                    // Example:
                    // false_car_working_platform
                    // false_car_shaft_prep
                    // false_car_master_rail
                    Text(
                      _display(activity.activityKey),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatus(
                activity.status,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==================================================
          // PROGRESS
          // ==================================================

          _buildProgress(activity),

          const SizedBox(height: 10),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 10),

          // ==================================================
          // DATES
          // ==================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'START DATE',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        activity.startDate,
                      ),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COMPLETED DATE',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        activity.completedDate,
                      ),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSTALLATION ACTIVITIES
  // ============================================================

  Widget _buildInstallationActivities() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        20,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // SECTION HEADER
          // ==================================================

          Row(
            children: [
              const Icon(
                Icons.check_box_outlined,
                size: 16,
                color: _primary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Installation Activities',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Activity count
              if (!_isLoadingActivities && _activityErrorMessage == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_activities.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ==================================================
          // LOADING
          // ==================================================

          if (_isLoadingActivities)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 30,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: _primary,
                ),
              ),
            )

          // ==================================================
          // ERROR
          // ==================================================

          else if (_activityErrorMessage != null)
            _buildActivityError()

          // ==================================================
          // EMPTY
          // ==================================================

          else if (_activities.isEmpty)
            _buildEmptyActivities()

          // ==================================================
          // DYNAMIC ACTIVITIES
          // ==================================================

          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final activity = _activities[index];

                return _buildActivityCard(
                  activity,
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVITY ERROR
  // ============================================================

  Widget _buildActivityError() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _activityErrorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _loadInstallationActivities,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(
                  color: _primary,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY ACTIVITIES
  // ============================================================

  Widget _buildEmptyActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 32,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'No installation activities found',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;

    return Scaffold(
      backgroundColor: _pageBackground,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: const Text(
          'Unit Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadInstallationActivities,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              _buildHeader(),

              // ==================================================
              // UNIT INFORMATION
              // ==================================================

              _buildInformationCard(
                title: 'Unit Information',
                children: [
                  _buildTwoColumnRow(
                    'Site Lift No',
                    unit.siteLiftName,
                    'Unit / Machine No',
                    unit.unitName,
                  ),
                  _buildTwoColumnRow(
                    'Capacity',
                    unit.capacity,
                    'Lift Speed',
                    unit.speed.isNotEmpty ? '${unit.speed} M/S' : null,
                  ),
                  _buildTwoColumnRow(
                    'Number of Stops',
                    unit.numberOfStops,
                    'Number of Openings',
                    unit.numberOfOpening,
                  ),
                  _buildTwoColumnRow(
                    'Travel Height',
                    unit.travelHeight,
                    'Door Size',
                    unit.doorSize,
                  ),
                  _buildTwoColumnRow(
                    'Door Type',
                    unit.doorTypeId,
                    'Door Model',
                    unit.doorModelId,
                  ),
                  _buildTwoColumnRow(
                    'Machine Room Type',
                    unit.machineRoomTypeId,
                    'Lift Type',
                    unit.typeId,
                  ),
                  _buildTwoColumnRow(
                    'Product Model Name',
                    unit.productModelName,
                    'Standard / Non Standard',
                    unit.standardType,
                  ),
                  _buildTwoColumnRow(
                    'Current Status',
                    unit.currentStatus,
                    'Start Date',
                    _formatDate(
                      unit.startDate,
                    ),
                  ),
                  _buildTwoColumnRow(
                    'Planned Finish',
                    _formatDate(
                      unit.endDate,
                    ),
                    'Actual Finish',
                    _formatDate(
                      unit.actualFinish,
                    ),
                  ),
                  _buildInfoRow(
                    'Method of Installation',
                    unit.methodName,
                  ),
                ],
              ),

              // ==================================================
              // INSTALLATION ACTIVITIES
              // ==================================================

              _buildInstallationActivities(),
            ],
          ),
        ),
      ),
    );
  }
}
