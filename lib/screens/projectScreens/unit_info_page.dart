import 'package:flutter/material.dart';
import '../../models/projectdetails/unit_info_model.dart';
import '../../service/service.dart';
import 'unit_info_details_page.dart';

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
  static const Color _pageBackground = Color(0xFFF1F5FB);

  List<UnitInfoData> _units = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnitInfo();
  }

  // ─────────────────────────────────────────────
  // Load Unit Information (API #1)
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
      } else {
        setState(() {
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to load unit information';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────
  // Header Card
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
  // Compact Unit Card
  // ─────────────────────────────────────────────
  Widget _buildUnitCard(UnitInfoData unit) {
    final title = unit.unitName.isNotEmpty
        ? unit.unitName
        : (unit.unitMachineNo.isNotEmpty
            ? 'Unit ${unit.unitMachineNo}'
            : 'Unit ${unit.id}');

    final siteLiftLabel = unit.siteLiftName.isNotEmpty
        ? unit.siteLiftName
        : (unit.siteLiftNo.isNotEmpty ? 'Site Lift ${unit.siteLiftNo}' : '--');

    final speedText = unit.speed.isNotEmpty ? '${unit.speed} M/S' : '--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UnitInfoDetailsPage(
                  unit: unit,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon + Title + Subtitle + Badge/Arrow
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
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            siteLiftLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (unit.standardType.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          unit.standardType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 12),

                // Compact details grid
                _buildCompactRow(
                  'Machine No.',
                  unit.unitMachineNo.isNotEmpty ? unit.unitMachineNo : '--',
                  'Capacity',
                  unit.capacity.isNotEmpty ? unit.capacity : '--',
                ),
                const SizedBox(height: 8),
                _buildCompactRow(
                  'Speed',
                  speedText,
                  'Stops / Openings',
                  '${unit.numberOfStops.isNotEmpty ? unit.numberOfStops : '--'} / ${unit.numberOfOpening.isNotEmpty ? unit.numberOfOpening : '--'}',
                ),
                if (unit.methodName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildCompactRow(
                    'Method',
                    unit.methodName,
                    null,
                    null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Compact 2-column key-value row
  // ─────────────────────────────────────────────
  Widget _buildCompactRow(
    String label1,
    String value1,
    String? label2,
    String? value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                '$label1: ',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  value1,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (label2 != null && value2 != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  '$label2: ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    value2,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Unit List
  // ─────────────────────────────────────────────
  Widget _buildUnitList() {
    if (_units.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.elevator_rounded,
                size: 40,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Text(
                'No unit information found',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
  // Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _loadUnitInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUnitInfo,
                  color: _primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
