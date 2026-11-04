import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/workstatus_model.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/service/service.dart';

class RunningWorkTimerService extends ChangeNotifier {
  RunningWorkTimerService._internal();
  static final RunningWorkTimerService instance =
      RunningWorkTimerService._internal();

  WorkStatusModel? workStatus;
  WorkStatus? existingWork;
  DateTime? createdAt;
  Duration elapsed = Duration.zero;

  Timer? _timer;
  String? _currentWorkId;
  String? _rawCreatedAt;
  bool _hasInitialized = false;
  Future<WorkStatusModel?>? _inFlightRefresh;

  bool get isRunning =>
      workStatus != null &&
      workStatus!.data.isNotEmpty &&
      existingWork != null &&
      createdAt != null;

  String get formattedTime =>
      "${elapsed.inHours}h ${elapsed.inMinutes % 60}m ${elapsed.inSeconds % 60}s";

  String get formattedClockTime =>
      "${elapsed.inHours.toString().padLeft(2, '0')}:"
      "${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:"
      "${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}";

  Future<void> ensureInitialized() async {
    if (!_hasInitialized) {
      await refresh();
    }
  }

  Future<WorkStatusModel?> refresh() {
    if (_inFlightRefresh != null) {
      return _inFlightRefresh!;
    }
    final future = _performRefresh();
    _inFlightRefresh = future;
    return future.whenComplete(() {
      if (identical(_inFlightRefresh, future)) {
        _inFlightRefresh = null;
      }
    });
  }

  Future<WorkStatusModel?> _performRefresh() async {
    final model = await HttpService.getWorkStatus();
    _hasInitialized = true;
    syncFromModel(model);
    return model;
  }

  void syncFromModel(WorkStatusModel? model) {
    _hasInitialized = true;
    workStatus = model;
    if (model != null && model.data.isNotEmpty) {
      final firstWork = model.data.first;
      existingWork = firstWork;

      if (_currentWorkId != firstWork.id ||
          _rawCreatedAt != firstWork.createdAt ||
          createdAt == null) {
        final parsed = _parseStartTime(firstWork);
        if (parsed != null) {
          createdAt = parsed;
        } else if (_currentWorkId != firstWork.id || createdAt == null) {
          createdAt = DateTime.now();
        }
        _currentWorkId = firstWork.id;
        _rawCreatedAt = firstWork.createdAt;
      }

      _updateElapsed();
      _startTimerIfNeeded();
    } else {
      existingWork = null;
      createdAt = null;
      _currentWorkId = null;
      _rawCreatedAt = null;
      elapsed = Duration.zero;
      _stopTimer();
    }
    notifyListeners();
  }

  void clear() {
    workStatus = null;
    existingWork = null;
    createdAt = null;
    _currentWorkId = null;
    _rawCreatedAt = null;
    elapsed = Duration.zero;
    _stopTimer();
    notifyListeners();
  }

  DateTime? _parseStartTime(WorkStatus work) {
    final candidates = [work.createdAt, work.loginTime];
    final formats = [
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd hh:mm a'),
      DateFormat('dd-MM-yyyy HH:mm:ss'),
      DateFormat('dd-MM-yyyy hh:mm a'),
      DateFormat('dd-MM-yyyy HH:mm'),
    ];

    for (final raw in candidates) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final isoParsed = DateTime.tryParse(trimmed);
      if (isoParsed != null) return isoParsed;
      for (final fmt in formats) {
        try {
          return fmt.parse(trimmed);
        } catch (_) {}
      }
    }
    return null;
  }

  void _updateElapsed() {
    if (createdAt == null) {
      elapsed = Duration.zero;
      return;
    }
    final diff = DateTime.now().difference(createdAt!);
    elapsed = diff.isNegative ? Duration.zero : diff;
  }

  void _startTimerIfNeeded() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isRunning) {
        _stopTimer();
        return;
      }
      _updateElapsed();
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

class RunningWorkTimerBadge extends StatefulWidget {
  final VoidCallback? onWorkUpdated;
  final bool enableTapNavigation;
  final EdgeInsetsGeometry? margin;
  final bool maintainSizeWhenHidden;

  const RunningWorkTimerBadge({
    super.key,
    this.onWorkUpdated,
    this.enableTapNavigation = true,
    this.margin,
    this.maintainSizeWhenHidden = false,
  });

  @override
  State<RunningWorkTimerBadge> createState() => _RunningWorkTimerBadgeState();
}

class _RunningWorkTimerBadgeState extends State<RunningWorkTimerBadge> {
  @override
  void initState() {
    super.initState();
    RunningWorkTimerService.instance.ensureInitialized();
  }

  Future<void> _handleTap(BuildContext context) async {
    if (!widget.enableTapNavigation) return;

    final workStatusModel = await RunningWorkTimerService.instance.refresh();
    WorkStatus? existingWork;
    if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
      existingWork = workStatusModel.data.first;
    }
    if (!context.mounted || existingWork == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkPage(
          workId: "",
          existingWork: existingWork,
          isAssigned: 1,
          onSuccess: () {
            RunningWorkTimerService.instance.refresh();
            widget.onWorkUpdated?.call();
          },
        ),
      ),
    );
    await RunningWorkTimerService.instance.refresh();
    widget.onWorkUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RunningWorkTimerService.instance,
      builder: (context, _) {
        final service = RunningWorkTimerService.instance;
        final visible = service.isRunning;

        if (!visible && !widget.maintainSizeWhenHidden) {
          return const SizedBox.shrink();
        }

        final pill = GestureDetector(
          onTap: widget.enableTapNavigation ? () => _handleTap(context) : null,
          child: Container(
            margin: widget.margin,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.red.shade100,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 15,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  service.formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        );

        if (widget.maintainSizeWhenHidden) {
          return Visibility(
            visible: visible,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: pill,
          );
        }

        return Center(child: pill);
      },
    );
  }
}

class TimeDifferenceWidget extends StatefulWidget {
  final String createdAt;

  const TimeDifferenceWidget({super.key, required this.createdAt});

  @override
  _TimeDifferenceWidgetState createState() => _TimeDifferenceWidgetState();
}

class _TimeDifferenceWidgetState extends State<TimeDifferenceWidget> {
  late Timer _timer;
  late Duration _timeDifference;
  late DateTime _createdAt;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _createdAt = DateTime.parse(widget.createdAt);
    _currentTime = DateTime.now();
    _timeDifference = _currentTime.difference(_createdAt);
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimeDifference);
  }

  void _updateTimeDifference(Timer timer) {
    setState(() {
      _currentTime = DateTime.now();
      _timeDifference = _currentTime.difference(_createdAt);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeString =
        "${_timeDifference.inHours}h ${_timeDifference.inMinutes % 60}m ${_timeDifference.inSeconds % 60}s";

    return Text(
      "Time since creation: $timeString",
      style: const TextStyle(fontSize: 24),
    );
  }
}
