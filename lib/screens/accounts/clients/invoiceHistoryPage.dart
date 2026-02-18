import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/invoiceListHistory.dart';
import 'package:login2/service/service.dart';

class InvoiceHistoryTimelinePage extends StatefulWidget {
  final String type;
  final String invId;
  final String? receipt;
  const InvoiceHistoryTimelinePage({
    Key? key,
    required this.type,
    required this.invId,
    this.receipt,
  }) : super(key: key);

  @override
  State<InvoiceHistoryTimelinePage> createState() =>
      _InvoiceHistoryTimelinePageState();
}

class _InvoiceHistoryTimelinePageState
    extends State<InvoiceHistoryTimelinePage> {
  bool isLoading = false;
  List<InvoiceLogData> timelineData = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final model =
          await HttpService.getInvoiceHistory(widget.type, widget.invId);
      if (model != null && model.status == true) {
        setState(() {
          timelineData = model.data ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: widget.receipt != "1"
            ? Text(
                'Invoice History',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              )
            : Text(
                'Receipt History',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
        backgroundColor: const Color.fromARGB(255, 64, 143, 207),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: fetchHistory,
        //     tooltip: 'Refresh',
        //   ),
        // ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Colors.grey[300],
            height: 0.5,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : timelineData.isEmpty
              ? _buildEmptyState()
              : _buildTimeline(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No History Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no timeline events to display',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return RefreshIndicator(
      onRefresh: fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timelineData.length,
        itemBuilder: (context, index) {
          final data = timelineData[index];
          final isLastItem = index == timelineData.length - 1;

          return _buildTimelineItem(data, isLastItem);
        },
      ),
    );
  }

  Widget _buildTimelineItem(InvoiceLogData data, bool isLastItem) {
    final color = Colors.blue;
    final icon = Icons.history;

    String timeAgo = "";
    String formattedTime = "";
    if (data.createdAt != null) {
      try {
        final timestamp = DateTime.parse(data.createdAt!);
        timeAgo = _getTimeAgo(timestamp);
        formattedTime = _getFormattedTime(timestamp);
      } catch (e) {
        timeAgo = data.createdAt!;
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column with icon and connector
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                if (!isLastItem)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withOpacity(0.5),
                            Colors.grey[300]!,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24, left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContentCard(data, color, timeAgo, formattedTime),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
      InvoiceLogData data, Color color, String timeAgo, String formattedTime) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: color,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "HISTORY LOG",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                if (data.rowId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "#${data.rowId}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.logData ?? "No data available",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Footer with staff and time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      data.proPicThumb != null && data.proPicThumb!.isNotEmpty
                          ? NetworkImage(data.proPicThumb!)
                          : null,
                  child: data.proPicThumb == null || data.proPicThumb!.isEmpty
                      ? Text(
                          (data.staffName != null && data.staffName!.isNotEmpty)
                              ? data.staffName![0]
                              : "?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.staffName ?? "Unknown Staff",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Staff Member",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getFormattedTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
