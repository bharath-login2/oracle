import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login2/key.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:get/get.dart';
import 'package:login2/service/service.dart';
import 'package:login2/screens/leadManagement/leadDetails.dart';
import 'package:login2/screens/leave_request_list_page.dart';

enum DeepLinkType { task, lead, leave_request, unknown }

class DeepLinkData {
  final DeepLinkType type;
  final String id;
  final String decodedId;

  DeepLinkData({
    required this.type,
    required this.id,
    required this.decodedId,
  });

  @override
  String toString() {
    return 'DeepLinkData(type: ${DeepLinkHandler._typeToString(type)}, id: $id, decodedId: $decodedId)';
  }
}

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal() {
    log('[DEEPLINK] DeepLinkHandler: Instance created');
  }

  String? _lastHandledLink;
  DateTime? _lastHandledTime;
  static const Duration _debounceDuration = Duration(seconds: 2);

  final AppLinks _appLinks = AppLinks();
  static String _typeToString(DeepLinkType type) {
    switch (type) {
      case DeepLinkType.task:
        return 'task';
      case DeepLinkType.lead:
        return 'lead';
      case DeepLinkType.leave_request:
        return 'leave_request';
      case DeepLinkType.unknown:
        return 'unknown';
    }
  }

  static DeepLinkType _stringToType(String typeStr) {
    switch (typeStr) {
      case 'task':
        return DeepLinkType.task;
      case 'lead':
        return DeepLinkType.lead;
      case 'leave_request':
        return DeepLinkType.leave_request;
      default:
        return DeepLinkType.unknown;
    }
  }

  DeepLinkData? parseDeepLink(String? url) {
    if (url == null || url.isEmpty) {
      print('No URL provided for deep link parsing');
      return null;
    }

    print('Parsing deep link URL: $url');

    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      print('Path: $path');

      if (path.startsWith('/redirect/task/')) {
        final segments = path.split('/redirect/task/');
        if (segments.length > 1) {
          final id = segments[1].split('?').first;
          print('Parsed task deep link with ID: $id');
          return DeepLinkData(
            type: DeepLinkType.task,
            id: id,
            decodedId: _decodeBase64(id),
          );
        }
      } else if (path.startsWith('/redirect/lead/')) {
        final segments = path.split('/redirect/lead/');
        if (segments.length > 1) {
          final id = segments[1].split('?').first;
          print('Parsed lead deep link with ID: $id');
          return DeepLinkData(
            type: DeepLinkType.lead,
            id: id,
            decodedId: _decodeBase64(id),
          );
        }
      } else if (path.startsWith('/redirect/leave_request/')) {
        final segments = path.split('/redirect/leave_request/');
        if (segments.length > 1) {
          final id = segments[1].split('?').first;
          print('Parsed leave_request deep link with ID: $id');
          return DeepLinkData(
            type: DeepLinkType.leave_request,
            id: id,
            decodedId: _decodeBase64(id),
          );
        }
      }

      print('No matching deep link pattern found');
      return null;
    } catch (e) {
      print('Error parsing deep link URL "$url": $e');
      return null;
    }
  }

  String _decodeBase64(String base64String) {
    try {
      String normalized =
          base64String.replaceAll('-', '+').replaceAll('_', '/');
      final padding = 4 - (normalized.length % 4);
      if (padding < 4) {
        normalized += '=' * padding;
      }
      final bytes = base64.decode(normalized);
      final decoded = utf8.decode(bytes);
      print('Decoded base64 "$base64String" -> "$decoded"');
      return decoded;
    } catch (e) {
      print('Base64 decode error for "$base64String": $e');
      return base64String;
    }
  }

  Future<String?> getInitialAppLink() async {
    try {
      final link = await _appLinks.getInitialLink();
      if (link != null) {
        print('Got initial app link: $link');
      }
      return link?.toString();
    } catch (e) {
      print('Error getting initial app link: $e');
      return null;
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      final isLoggedIn = token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty;
      log('User login status: $isLoggedIn (token present: ${token != null}, userId present: ${userId != null})');
      return isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<void> storePendingDeepLink(DeepLinkData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_deep_link_type', _typeToString(data.type));
      await prefs.setString('pending_deep_link_id', data.id);
      await prefs.setString('pending_deep_link_decoded', data.decodedId);
      print('Stored pending deep link: $data');
    } catch (e) {
      print('Error storing pending deep link: $e');
    }
  }

  Future<DeepLinkData?> getPendingDeepLink() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeStr = prefs.getString('pending_deep_link_type');
      final id = prefs.getString('pending_deep_link_id');
      final decoded = prefs.getString('pending_deep_link_decoded');

      if (typeStr == null || id == null) {
        print('No pending deep link found');
        return null;
      }

      print('Retrieved pending deep link: type=$typeStr, id=$id');

      await prefs.remove('pending_deep_link_type');
      await prefs.remove('pending_deep_link_id');
      await prefs.remove('pending_deep_link_decoded');

      return DeepLinkData(
        type: _stringToType(typeStr),
        id: id,
        decodedId: decoded ?? _decodeBase64(id),
      );
    } catch (e) {
      print('Error getting pending deep link: $e');
      return null;
    }
  }

  Future<bool> hasPendingDeepLink() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeStr = prefs.getString('pending_deep_link_type');
      final id = prefs.getString('pending_deep_link_id');
      return typeStr != null && id != null;
    } catch (e) {
      print('Error checking pending deep link: $e');
      return false;
    }
  }

  Future<void> clearPendingDeepLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_deep_link_type');
      await prefs.remove('pending_deep_link_id');
      await prefs.remove('pending_deep_link_decoded');
      print('Cleared all pending deep links');
    } catch (e) {
      print('Error clearing pending deep links: $e');
    }
  }

  Future<void> checkAndHandlePendingDeepLink() async {
    log('[DEEPLINK] DeepLinkHandler: Checking for pending deep links');
    final data = await getPendingDeepLink();
    if (data != null) {
      log('[DEEPLINK] DeepLinkHandler: Found pending deep link: $data');
      final context = NoomiKeys.navKey.currentContext;
      if (context != null) {
        // Wait a bit for the dashboard to be ready
        Future.delayed(const Duration(milliseconds: 500), () {
          validateAndNavigate(context, data);
        });
      } else {
        log('[DEEPLINK] DeepLinkHandler: No context available for pending deep link');
        // Put it back if we really can't handle it now? Or just handle via Get
        handleDeepLinkNavigation(data);
      }
    }
  }

  Future<void> handleAppLink(String? link) async {
    if (link == null) {
      log('[DEEPLINK] DeepLinkHandler: No link to handle');
      return;
    }

    final now = DateTime.now();
    if (_lastHandledLink == link &&
        _lastHandledTime != null &&
        now.difference(_lastHandledTime!) < _debounceDuration) {
      log('[DEEPLINK] DeepLinkHandler: Ignoring duplicate link within debounce period: $link');
      return;
    }

    _lastHandledLink = link;
    _lastHandledTime = now;

    log('[DEEPLINK] DeepLinkHandler: Handling app link: $link');

    final data = parseDeepLink(link);
    if (data == null) {
      log('[DEEPLINK] DeepLinkHandler: Could not parse deep link from URL');
      return;
    }

    final isLoggedIn = await isUserLoggedIn();
    log('[DEEPLINK] DeepLinkHandler: User logged in: $isLoggedIn');

    if (isLoggedIn) {
      log('[DEEPLINK] DeepLinkHandler: User is logged in, validating and navigating');
      final context = NoomiKeys.navKey.currentContext;
      if (context != null) {
        validateAndNavigate(context, data);
      } else {
        log('[DEEPLINK] DeepLinkHandler: Context is null, storing pending');
        await storePendingDeepLink(data);
      }
    } else {
      log('[DEEPLINK] DeepLinkHandler: User not logged in, storing deep link');
      await storePendingDeepLink(data);
    }
  }

  Future<void> validateAndNavigate(
      BuildContext context, DeepLinkData data) async {
    print('Validating deep link: $data');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    bool isValid = false;
    try {
      if (data.type == DeepLinkType.task) {
        final status =
            await HttpService.getAssinedWorkStatus(data.decodedId, "");
        if (status != null && status.data != null && status.data!.isNotEmpty) {
          isValid = true;
        }
      } else if (data.type == DeepLinkType.lead) {
        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        if (token != null) {
          final details = await HttpService.leadDetails(token, data.decodedId);
          if (details != null && details.data != null) {
            isValid = true;
          }
        }
      } else if (data.type == DeepLinkType.leave_request) {
        isValid = true;
      }
    } catch (e) {
      print('Error validating deep link: $e');
    }

    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (isValid) {
      handleDeepLinkNavigation(data);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Url is not valid for the current login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void handleDeepLinkNavigation(DeepLinkData data) {
    print('Handling deep link navigation for: $data');
    if (data.type == DeepLinkType.task) {
      final context = NoomiKeys.navKey.currentContext;
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: data.decodedId,
              sectionId: "",
            ),
          ),
        );
      } else {
        Get.to(() => AssignReport(
              workId: data.decodedId,
              sectionId: "",
            ));
      }
    } else if (data.type == DeepLinkType.leave_request) {
      final context = NoomiKeys.navKey.currentContext;
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LeaveRequestListPage(),
          ),
        );
      } else {
        Get.to(() => const LeaveRequestListPage());
      }
    } else if (data.type == DeepLinkType.lead) {
      _handleLeadNavigation(data);
    }
  }

  Future<void> _handleLeadNavigation(DeepLinkData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? editLead = prefs.getString("updateLeadPermission");
      String? deleteLead = prefs.getString("deleteLeadPermission");
      String? cloudCall = prefs.getString("cloudCallPermission");

      if (token == null) {
        print('Cannot navigate to lead: Token is null');
        return;
      }

      bool canEdit = (editLead?.toLowerCase() == "true");
      bool canDelete = (deleteLead?.toLowerCase() == "true");
      bool canCloudCall = (cloudCall?.toLowerCase() == "true");

      final context = NoomiKeys.navKey.currentContext;
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LeadDetails(
              token,
              canEdit,
              canDelete,
              canCloudCall,
              data.decodedId,
              fromDate: DateTime.now().toString(),
              toDate: DateTime.now().toString(),
              pageName: "notification",
            ),
          ),
        );
      } else {
        Get.to(() => LeadDetails(
              token,
              canEdit,
              canDelete,
              canCloudCall,
              data.decodedId,
              fromDate: DateTime.now().toString(),
              toDate: DateTime.now().toString(),
              pageName: "notification",
            ));
      }
    } catch (e) {
      print('Error navigating to lead details: $e');
    }
  }

  StreamSubscription<String>? _subscription;

  void startListening(Function(String) onLinkReceived) {
    if (_subscription != null) return;
    _subscription = _appLinks.stringLinkStream.listen((link) {
      onLinkReceived(link);
    }, onError: (error) {
      print('Error in app link stream: $error');
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
  }
}

final deepLinkHandler = DeepLinkHandler();
