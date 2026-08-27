import 'package:flutter/material.dart';
import '../../models/projectdetails/unit_info_model.dart';
import '../../service/service.dart';
import 'add_unit_info_page.dart';

class UnitInfoPage extends StatefulWidget {
  final String projectId;

  const UnitInfoPage({
    super.key,
    required this.projectId,
  });

  @override
  State<UnitInfoPage> createState() => _UnitInfoPageState();
}

class _UnitInfoPageState extends State<UnitInfoPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  List<UnitInfoData> _units = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnitInfo();
  }

  // ─────────────────────────────────────────────
  // Load Unit Information
  // ─────────────────────────────────────────────
  Future<void> _loadUnitInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await HttpService.getUnitInfo(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _units = response.unit;
          _isLoading = false;
        });

        debugPrint('Unit count: ${_units.length}');
      } else {
        setState(() {
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to load unit information';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('getUnitInfo error: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────
  // Unit Header Card
  // ─────────────────────────────────────────────
  Widget _buildHeaderCard() {
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.elevator_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${_units.length} Units',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Section Title
  // ─────────────────────────────────────────────
  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          SizedBox(
            width: 4,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.all(
                  Radius.circular(2),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Unit Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Unit List
  // ─────────────────────────────────────────────
  Widget _buildUnitList() {
    if (_units.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'No unit information found',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _units.length,
        itemBuilder: (context, index) {
          final unit = _units[index];

          return _buildUnitCard(unit);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Unit Card
  // ─────────────────────────────────────────────
  Widget _buildUnitCard(UnitInfoData unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.elevator_rounded,
                  color: _primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.unitName.isNotEmpty
                          ? unit.unitName
                          : 'Unit ${unit.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.siteLiftName.isNotEmpty
                          ? unit.siteLiftName
                          : 'Site Lift ${unit.siteLiftNo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => AddUnitInfoPage(
                  //       projectId: widget.projectId,
                  //       isEdit: true,
                  //       siteLiftNo: unit.siteLiftNo,
                  //       unitMachineNo: unit.unitMachineNo,
                  //       // installationMethod: unit.installationMethod,
                  //     ),
                  //   ),
                  // );
                },
                tooltip: 'Edit',
                icon: Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 21,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _primary.withOpacity(0.08),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(38, 38),
                ),
              ),

              const SizedBox(width: 4),

              // Delete button
              IconButton(
                onPressed: () {
                  _deleteUnit(unit);
                },
                tooltip: 'Delete',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 21,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.08),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(38, 38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSmallInfo(
            'Machine No.',
            unit.unitMachineNo,
          ),
          _buildSmallInfo(
            'Capacity',
            unit.capacity,
          ),
          _buildSmallInfo(
            'Speed',
            unit.speed.isNotEmpty ? '${unit.speed} M/S' : '--',
          ),
          _buildSmallInfo(
            'Stops',
            unit.numberOfStops,
          ),
          _buildSmallInfo(
            'Openings',
            unit.numberOfOpening,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showUnitDetails(unit);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(
                  color: _primary.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Small Info
  // ─────────────────────────────────────────────
  Widget _buildSmallInfo(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '--',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
// Detail Section
// ─────────────────────────────────────────────
  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: children,
          ),
        ],
      ),
    );
  }

// ─────────────────────────────────────────────
// Detail Grid Item
// ─────────────────────────────────────────────
  Widget _buildDetailGridItem(
    String title,
    String value,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          width: width > 500 ? (width - 12) / 2 : width,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isNotEmpty ? value : '--',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
// Full Unit Details
// ─────────────────────────────────────────────
  void _showUnitDetails(UnitInfoData unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5FB),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  14,
                  12,
                  14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _primary,
                            _primaryDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.elevator_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.unitName.isNotEmpty
                                ? unit.unitName
                                : 'Unit ${unit.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit.siteLiftName.isNotEmpty
                                ? unit.siteLiftName
                                : 'Site Lift ${unit.siteLiftNo}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection(
                        title: 'Basic Information',
                        icon: Icons.info_outline_rounded,
                        children: [
                          _buildDetailGridItem(
                            'Site Lift No.',
                            unit.siteLiftNo,
                          ),
                          _buildDetailGridItem(
                            'Unit / Machine No.',
                            unit.unitMachineNo,
                          ),
                          _buildDetailGridItem(
                            'Capacity',
                            unit.capacity,
                          ),
                          _buildDetailGridItem(
                            'Lift Speed',
                            unit.speed.isNotEmpty ? '${unit.speed} M/S' : '',
                          ),
                          _buildDetailGridItem(
                            'Number of Stops',
                            unit.numberOfStops,
                          ),
                          _buildDetailGridItem(
                            'Number of Openings',
                            unit.numberOfOpening,
                          ),
                          _buildDetailGridItem(
                            'Travel Height',
                            unit.travelHeight,
                          ),
                          _buildDetailGridItem(
                            'Door Size',
                            unit.doorSize,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildDetailSection(
                        title: 'Technical Information',
                        icon: Icons.settings_outlined,
                        children: [
                          _buildDetailGridItem(
                            'Door Type',
                            unit.doorTypeId,
                          ),
                          _buildDetailGridItem(
                            'Door Model',
                            unit.doorModelId,
                          ),
                          _buildDetailGridItem(
                            'Machine Room Type',
                            unit.machineRoomTypeId,
                          ),
                          _buildDetailGridItem(
                            'Lift Type',
                            unit.typeId,
                          ),
                          _buildDetailGridItem(
                            'Product Model',
                            unit.productModelName,
                          ),
                          _buildDetailGridItem(
                            'Standard Type',
                            unit.standardType,
                          ),
                          _buildDetailGridItem(
                            'Room Type',
                            unit.roomType,
                          ),
                          _buildDetailGridItem(
                            'Model Name',
                            unit.modelName,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildDetailSection(
                        title: 'Project & Installation',
                        icon: Icons.engineering_outlined,
                        children: [
                          _buildDetailGridItem(
                            'Current Status',
                            unit.status,
                          ),
                          _buildDetailGridItem(
                            'Start Date',
                            unit.startDate,
                          ),
                          _buildDetailGridItem(
                            'Planned Finish',
                            unit.endDate,
                          ),
                          _buildDetailGridItem(
                            'Actual Finish',
                            unit.actualFinish,
                          ),
                          _buildDetailGridItem(
                            'Installation Method',
                            unit.methodName,
                          ),
                          _buildDetailGridItem(
                            'Completion',
                            unit.percentage.isNotEmpty
                                ? '${unit.percentage}%'
                                : '',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editUnit(UnitInfoData unit) {
    // Open edit page/dialog
    debugPrint('Edit unit: ${unit.id}');
  }

  void _deleteUnit(UnitInfoData unit) {
    // Delete API call
    debugPrint('Delete unit: ${unit.id}');
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Unit Information',
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

        // Add Unit button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddUnitInfoPage(
                      projectId: widget.projectId,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],

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
          ? const Center(
              child: CircularProgressIndicator(
                color: _primary,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadUnitInfo,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUnitInfo,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        _buildSectionTitle(),
                        _buildUnitList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}
