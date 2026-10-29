import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login2/models/lead_management/newProjectListModel.dart';
import 'package:login2/models/lead_management/projectDetailedModel.dart';
// import 'package:login2/models/projectdetails/project_documents_models.dart';
import '../projectScreens/project_info.dart';
import '../projectScreens/unit_info.dart';
import '../projectScreens/delay_management.dart';
import '../projectScreens/project_documents.dart';
import '../projectScreens/gallery.dart';
import '../projectScreens/site_drawings.dart';
// import '../projectScreens/payment_schedule_screen.dart';
// import '../projectScreens/extra_work.dart';
// import '../projectScreens/deduction_work.dart';
// import '../projectScreens/expense.dart';
// import '../projectScreens/payment_history.dart';
import 'package:login2/service/service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Indian-style grouping (12,50,000) without extra packages.
String _formatAmount(double value, {int decimals = 0}) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final digits = parts[0];

  String grouped;
  if (digits.length <= 3) {
    grouped = digits;
  } else {
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    grouped = '${groups.join(',')},$last3';
  }
  final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
  return '${negative ? '-' : ''}₹$grouped$decimalPart';
}

/// Fade + slide + scale entrance, optionally delayed (for staggering).
class _AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedEntrance({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<_AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final curved =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = curved;
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(curved);
    _scale = Tween<double>(begin: 0.94, end: 1).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

/// Shrinks slightly while a finger is down. Uses raw pointer events, so it
/// doesn't interfere with the child's InkWell ripple or onTap.
class _PressScale extends StatefulWidget {
  final Widget child;
  final double pressedScale;

  const _PressScale({required this.child, this.pressedScale = 0.95});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Small glowing dot used in the "running" status chip.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.55 * t),
                blurRadius: 4 + 6 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

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
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Header card (name / client / location / status) ─────────────────────
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

  Widget _buildStatusChip(String status) {
    if (status.isEmpty) return const SizedBox.shrink();
    final s = status.toLowerCase();
    final isRunning = s == 'running';
    final color = isRunning
        ? const Color(0xFF2E9E5B)
        : s == 'completed'
            ? _primary
            : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRunning)
              _PulsingDot(color: color)
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            const SizedBox(width: 6),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
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
                      _buildStatusChip(d.workStatus),
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

  // ── Overview card (animated metric cards) ───────────────────────────────
  Widget _buildOverviewCard(ProjectDetailedData d) {
    final metrics = <Map<String, dynamic>>[
      {
        'title': 'Total Project Cost',
        'count': d.totalProjectCost,
        'icon': Icons.currency_rupee_rounded,
        'colors': const [Color(0xFF2A86C9), Color(0xFF1A5FA8)],
      },
      {
        'title': 'Received from Client',
        'count': d.receivedFromClient,
        'icon': Icons.call_received_rounded,
        'colors': const [Color(0xFF26A69A), Color(0xFF00796B)],
      },
      {
        'title': 'Total Expense Payment',
        'count': d.totalExpensePayment,
        'icon': Icons.call_made_rounded,
        'colors': const [Color(0xFFFF8A65), Color(0xFFE64A19)],
      },
      {
        'title': 'Total Purchase Payment',
        'count': d.totalPurchasePayment,
        'icon': Icons.shopping_cart_rounded,
        'colors': const [Color(0xFF7E57C2), Color(0xFF512DA8)],
      },
    ];

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 130,
            ),
            itemBuilder: (context, i) {
              final m = metrics[i];
              final count = m['count'] as double;
              // Share of total project cost (for every card except the first)
              final double? ratio = (i > 0 && d.totalProjectCost > 0)
                  ? (count / d.totalProjectCost).clamp(0.0, 1.0).toDouble()
                  : null;

              return _AnimatedEntrance(
                delay: Duration(milliseconds: 150 + i * 110),
                child: _buildMetricCard(
                  title: m['title'] as String,
                  count: count,
                  icon: m['icon'] as IconData,
                  gradientColors: m['colors'] as List<Color>,
                  filterType: m['title'] as String,
                  ratio: ratio,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double count,
    required IconData icon,
    required List<Color> gradientColors,
    required String filterType,
    double? ratio,
  }) {
    return _PressScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withOpacity(0.2),
          onTap: () => _showMetricDetails(
            title: title,
            count: count,
            icon: icon,
            colors: gradientColors,
            ratio: ratio,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Soft watermark icon in the corner
                  Positioned(
                    right: -12,
                    bottom: -16,
                    child: Icon(
                      icon,
                      size: 80,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top: icon (left) + animated price (right)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: count),
                                  duration: const Duration(milliseconds: 1400),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, value, __) => Text(
                                    _formatAmount(value),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Bottom: title
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet shown when a metric card is tapped.
  void _showMetricDetails({
    required String title,
    required double count,
    required IconData icon,
    required List<Color> colors,
    double? ratio,
  }) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.last.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: count),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatAmount(value, decimals: 2),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: colors.last,
                      ),
                    ),
                  ),
                ),
                if (ratio != null) ...[
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Share of total project cost',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${(value * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.last,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: colors.last.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.first,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Section action buttons ──────────────────────────────────────────────
  Widget _buildActionButton(_ActionItem item) {
    return _PressScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            item.onTap();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: _primary.withOpacity(0.15),
          child: Ink(
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
                  child: Icon(item.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.label,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_ActionItem> _actions() {
    final p = widget.project;
    return [
      _ActionItem(
        label: 'Project Info',
        icon: Icons.info_outline_rounded,
        onTap: () => _open(ProjectInfoPage(project: p)),
      ),
      _ActionItem(
        label: 'Project Document',
        icon: Icons.description_outlined,
        onTap: () => _open(ProjectDocumentsPage(project: p)),
      ),
      _ActionItem(
        label: 'Delay Management',
        icon: Icons.timer_off_outlined,
        onTap: () => _open(DelayManagementPage(
          projectId: p.id.toString(),
          projectNo: p.projectNo.toString(),
        )),
      ),
      _ActionItem(
        label: 'Gallery',
        icon: Icons.photo_library_outlined,
        onTap: () => _open(GalleryPage(
          projectId: p.id.toString(),
          projectNo: p.projectNo.toString(),
          clientId: p.clientId,
        )),
      ),
      // Payment Schedule → Payment History are UI-only for now
      // _ActionItem(
      //   label: 'Payment Schedule',
      //   icon: Icons.payment_outlined,
      //   onTap: () => _open(PaymentScheduleScreen(
      //     projectId: p.id,
      //     projectNo: p.projectNo.toString(),
      //   )),
      // ),
      _ActionItem(
        label: 'Site Drawings',
        icon: Icons.architecture_outlined,
        onTap: () => _open(SiteDrawingPage(
          projectId: p.id,
          projectNo: p.projectNo,
          clientId: p.clientId,
          projectStatus: p.paymentStatus,
        )),
      ),
      // _ActionItem(
      //   label: 'Extra Work',
      //   icon: Icons.trending_up,
      //   onTap: () => _open(ExtraWorkScreen(
      //     projectId: p.id,
      //     projectNo: p.projectNo,
      //     clientId: p.clientId,
      //   )),
      // ),
      // _ActionItem(
      //   label: 'Deduction Work',
      //   icon: Icons.trending_down,
      //   onTap: () => _open(DeductionWorkScreen(
      //     projectId: p.id,
      //     projectNo: p.projectNo,
      //     clientId: p.clientId,
      //   )),
      // ),
      // _ActionItem(
      //   label: 'Expenses',
      //   icon: Icons.account_balance_wallet_outlined,
      //   onTap: () => _open(ExpenseScreen(
      //     projectId: p.id,
      //     projectNo: p.projectNo,
      //     clientId: p.clientId,
      //   )),
      // ),
      // _ActionItem(
      //   label: 'Payment History',
      //   icon: Icons.receipt_long_rounded,
      //   onTap: () => _open(PaymentHistoryScreen(
      //     projectId: p.id,
      //     projectNo: p.projectNo,
      //     clientId: p.clientId,
      //   )),
      // ),
      _ActionItem(
        label: 'Unit Info',
        icon: Icons.home_work_outlined,
        onTap: () => _open(UnitInfoPage(projectId: p.id)),
      ),
    ];
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final d = _projectData;
    final actions = _actions();

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
          : (_errorMessage != null || d == null)
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
                          _errorMessage ?? 'No data available',
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
              : RefreshIndicator(
                  color: _primary,
                  onRefresh: _fetchProjectDetailed,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1 – Project identity card
                        _AnimatedEntrance(child: _buildHeaderCard(d)),

                        // 2 – Overview: animated metric cards
                        _AnimatedEntrance(
                          delay: const Duration(milliseconds: 80),
                          child: _buildOverviewCard(d),
                        ),

                        // 3 – Section label
                        _AnimatedEntrance(
                          delay: const Duration(milliseconds: 250),
                          child: Padding(
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
                        ),

                        // 4 – Staggered grid of action buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: actions.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 118,
                            ),
                            itemBuilder: (context, i) {
                              return _AnimatedEntrance(
                                delay: Duration(
                                  milliseconds: 300 + (i * 60),
                                ),
                                child: _buildActionButton(actions[i]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
