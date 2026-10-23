import 'package:flutter/material.dart';
import './quotationListScreen.dart';
import './amcListScreen.dart';
import './repairingListScreen.dart';

class DashboardQuotationScreen extends StatefulWidget {
  const DashboardQuotationScreen({super.key});

  @override
  State<DashboardQuotationScreen> createState() =>
      _DashboardQuotationScreenState();
}

class _DashboardQuotationScreenState extends State<DashboardQuotationScreen> {
  // Layout constants
  static const double _maxContentWidth = 900;
  static const double _wideBreakpoint = 700;
  static const double _baseCardHeight = 132;
  static const double _spacing = 12;

  static const Color _titleColor = Color(0xFF1E293B);

  // Pull-to-refresh handler
  Future<void> _handleRefresh() async {
    // Simulate network delay or fetch fresh data here
    await Future.delayed(const Duration(milliseconds: 1500));

    // Call setState if you need to update dashboard metrics/counts
    setState(() {
      // Refresh logic or counter updates go here
    });
  }

  @override
  Widget build(BuildContext context) {
    // Card height grows with the user's system font scale so text never overflows.
    final double textScale =
        (MediaQuery.textScalerOf(context).scale(10) / 10).clamp(1.0, 1.8);
    final double cardHeight = _baseCardHeight * textScale;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A86C9), Color(0xFF406DBE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Quotations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF2A86C9),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even when content doesn't fill the screen
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth >= _wideBreakpoint;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ---------- Quotation Requests ----------
                        // _sectionTitle('Quotation Requests'),
                        // const SizedBox(height: _spacing),
                        // _buildRequestsSection(isWide, cardHeight),
                        // const SizedBox(height: 24),

                        // ---------- Quotations Overview ----------
                        _sectionTitle('Quotations Overview'),
                        const SizedBox(height: _spacing),
                        _buildOverviewGrid(cardHeight),
                        const SizedBox(height: 24),

                        // ---------- Quick Actions ----------
                        _sectionTitle('Quick Actions'),
                        const SizedBox(height: _spacing),
                        _buildQuickActions(isWide),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Sections
  // ------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _titleColor,
      ),
    );
  }

  // Widget _buildRequestsSection(bool isWide, double cardHeight) {
  //   final total = _buildMetricCard(
  //     title: 'TOTAL REQUESTS',
  //     value: '88',
  //     subtitle: 'Total requests received',
  //     badgeText: 'Overall',
  //     badgeColor: const Color(0xFFDCFCE7),
  //     badgeTextColor: const Color(0xFF166534),
  //     indicatorColor: const Color(0xFF2A86C9),
  //     icon: Icons.description_outlined,
  //     iconColor: const Color(0xFF2A86C9),
  //   );

  //   final pending = _buildMetricCard(
  //     title: 'PENDING',
  //     value: '71',
  //     subtitle: 'Awaiting action',
  //     indicatorColor: const Color(0xFFF59E0B),
  //     icon: Icons.access_time_rounded,
  //     iconColor: const Color(0xFFF59E0B),
  //   );

  //   final completed = _buildMetricCard(
  //     title: 'COMPLETED',
  //     value: '10',
  //     subtitle: 'Processed requests',
  //     indicatorColor: const Color(0xFF10B981),
  //     icon: Icons.check_circle_outline,
  //     iconColor: const Color(0xFF10B981),
  //   );

  //   // Wide screens: all three cards in one row.
  //   if (isWide) {
  //     return SizedBox(
  //       height: cardHeight,
  //       child: Row(
  //         children: [
  //           Expanded(child: total),
  //           const SizedBox(width: _spacing),
  //           Expanded(child: pending),
  //           const SizedBox(width: _spacing),
  //           Expanded(child: completed),
  //         ],
  //       ),
  //     );
  //   }

  //   // Phones: total on top, pending + completed side by side below.
  //   return Column(
  //     children: [
  //       SizedBox(height: cardHeight, width: double.infinity, child: total),
  //       const SizedBox(height: _spacing),
  //       SizedBox(
  //         height: cardHeight,
  //         child: Row(
  //           children: [
  //             Expanded(child: pending),
  //             const SizedBox(width: _spacing),
  //             Expanded(child: completed),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildOverviewGrid(double cardHeight) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: cardHeight,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
      ),
      children: [
        _buildMetricCard(
          title: 'TOTAL GENERATED',
          value: '56',
          subtitle: 'Total created',
          indicatorColor: const Color(0xFF06B6D4),
          icon: Icons.file_copy_outlined,
          iconColor: const Color(0xFF06B6D4),
        ),
        _buildMetricCard(
          title: 'ADMIN APPROVED',
          value: '6',
          subtitle: 'Approved by Admin',
          indicatorColor: const Color(0xFF10B981),
          icon: Icons.thumb_up_alt_outlined,
          iconColor: const Color(0xFF10B981),
        ),
        _buildMetricCard(
          title: 'REJECTED',
          value: '3',
          subtitle: 'Declined status',
          indicatorColor: const Color(0xFFEF4444),
          icon: Icons.cancel_outlined,
          iconColor: const Color(0xFFEF4444),
        ),
        _buildMetricCard(
          title: 'CLIENT APPROVED',
          value: '12',
          subtitle: 'Client Approved',
          indicatorColor: const Color(0xFF8B5CF6),
          icon: Icons.send_rounded,
          iconColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isWide) {
    final tiles = <Widget>[
      _buildNavTile(
        title: 'Quotation',
        subtitle: 'Manage quotation requests',
        icon: Icons.request_quote_outlined,
        color: const Color(0xFF2A86C9),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const QuotationListScreen()),
          );
        },
      ),
      _buildNavTile(
        title: 'AMC',
        subtitle: 'Annual maintenance contracts ',
        icon: Icons.verified_user_outlined,
        color: const Color(0xFF8B5CF6),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AMCListScreen()),
          );
        },
      ),
      _buildNavTile(
        title: 'Repairing',
        subtitle: 'Track service requests and repair orders',
        icon: Icons.handyman_outlined,
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RepairingListScreen()),
          );
        },
      ),
    ];

    // Wide screens: tiles side by side, equal height.
    if (isWide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: _spacing),
              Expanded(child: tiles[i]),
            ],
          ],
        ),
      );
    }

    // Phones: stacked.
    return Column(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(height: _spacing),
          tiles[i],
        ],
      ],
    );
  }

  // ------------------------------------------------------------------
  // Reusable widgets
  // ------------------------------------------------------------------

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    required Color indicatorColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
