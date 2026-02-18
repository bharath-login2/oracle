import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeepLinkType { task, lead, unknown }

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
  DeepLinkHandler._internal();

  final AppLinks _appLinks = AppLinks();
  static String _typeToString(DeepLinkType type) {
    switch (type) {
      case DeepLinkType.task:
        return 'task';
      case DeepLinkType.lead:
        return 'lead';
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
      // Mjky should decode to 292
      // Handle URL-safe base64
      String normalized =
          base64String.replaceAll('-', '+').replaceAll('_', '/');

      // Add padding if needed
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

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');
      final isLoggedIn = token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty;
      print('User login status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Store pending deep link for later use (when user is not logged in)
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

  // Get and clear pending deep link
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

      // Clear after reading
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

  // Check if there's a pending deep link without clearing it
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

  // Clear all pending deep links
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

  // Method to handle app link from anywhere in the app
  Future<void> handleAppLink(String? link) async {
    if (link == null) {
      print('No link to handle');
      return;
    }

    print('Handling app link: $link');

    final data = parseDeepLink(link);
    if (data == null) {
      print('Could not parse deep link from URL');
      return;
    }

    final isLoggedIn = await isUserLoggedIn();

    if (isLoggedIn) {
      print('User is logged in, deep link can be processed immediately');
      await storePendingDeepLink(data);
      // The app should check for pending links and navigate
    } else {
      print('User is not logged in, storing deep link for later');
      await storePendingDeepLink(data);
    }
  }

  // Initialize deep link listening (app_links 3.2.1 version)
  StreamSubscription<String>? _subscription;

  void startListening(Function(String) onLinkReceived) {
    // In app_links 3.2.1, stringLinkStream returns String
    _subscription = _appLinks.stringLinkStream.listen((link) {
      print('Received app link via stream: $link');
      onLinkReceived(link);
    }, onError: (error) {
      print('Error in app link stream: $error');
    });

    print('Started listening to app links');
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    print('Stopped listening to app links');
  }

  // Dispose method for cleanup
  void dispose() {
    stopListening();
  }
}

// Global instance for easy access
final deepLinkHandler = DeepLinkHandler();
