import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:login2/models/serviceman/pushNotificationModel.dart';
import 'package:login2/screens/serviceman/workList.dart';
import 'package:login2/service/service.dart';

class NotificationPageService extends StatefulWidget {
  const NotificationPageService({super.key});

  @override
  State<NotificationPageService> createState() => _NotificationPageServiceState();
}

class _NotificationPageServiceState extends State<NotificationPageService> {
  late HttpService _httpService;
  List<NotificationData> _notifications = [];
  bool _isLoading = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _httpService = HttpService();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _httpService.getPushNotification();
      if (response != null && response.status == true) {
        setState(() {
          _notifications = response.data ?? [];
        });
      } else {
        log("Failed to load notifications");
      }
    } catch (e) {
      log("Error loading notifications: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 160, 43, 35),foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _httpService.deletePushNotification(notificationId);
      if (success) {
        setState(() {
          _notifications.removeWhere((n) => n.notifictionId == notificationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification deleted")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete notification")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _showAll
        ? _notifications
        : _notifications.take(10).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 16, 37, 105),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No Notifications',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == displayList.length) {
                        final hasMore = _notifications.length > 10;
                        if (!hasMore) return const SizedBox();
                        return Center(
                          child: TextButton(
                            onPressed: () => setState(() => _showAll = !_showAll),
                            child: Text(
                              _showAll ? "See Less" : "See More",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      final n = displayList[index];
                      return Dismissible(
                        key: Key(n.notifictionId ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteNotification(n.notifictionId ?? '');
                          return false; 
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(
                              Icons.notifications_active,
                              color: Colors.blue,
                            ),
                            title: Text(
                              n.title ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(n.message ?? ''),
                            trailing: Text(
                              n.timeAgo ?? '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkListPage(
                                    pageTitle: "All Works",
                                    typeId: "5",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

