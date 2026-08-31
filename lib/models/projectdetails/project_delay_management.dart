import 'dart:convert';
import 'dart:developer';

class ProjectDelayResponse {
  final List<ProjectDelay> data;
  final String message;
  final bool status;

  ProjectDelayResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ProjectDelayResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return ProjectDelayResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map((e) => ProjectDelay.fromJson(e))
              .toList()
          : [],
    );
  }
}

class ProjectDelay {
  final String id;
  final String projectId;
  final String projectNo;
  final String unitNo;
  final String siteLiftNo;
  final String delayTypeId;
  final String delayTypeName;
  final String looseTypeId;
  final String looseTypeName;
  final String responsiblePartyId;
  final String createdAt;
  final List<String> supportingPhotoFileIds;

  ProjectDelay({
    required this.id,
    required this.projectId,
    required this.projectNo,
    required this.unitNo,
    required this.siteLiftNo,
    required this.delayTypeId,
    required this.delayTypeName,
    required this.looseTypeId,
    required this.looseTypeName,
    required this.responsiblePartyId,
    required this.createdAt,
    required this.supportingPhotoFileIds,
  });

  factory ProjectDelay.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['supporting_photo_file_ids'];

    List<String> photoIds = [];

    if (rawPhotos is List) {
      // If API already gives a List
      photoIds = rawPhotos
          .map((e) => e.toString().trim())
          .where((id) => id.isNotEmpty)
          .toList();
    } else if (rawPhotos is String && rawPhotos.trim().isNotEmpty) {
      // API currently gives a JSON String:
      // "[\"id1\",\"id2\"]"
      try {
        final decoded = jsonDecode(rawPhotos);

        if (decoded is List) {
          photoIds = decoded
              .map((e) => e.toString().trim())
              .where((id) => id.isNotEmpty)
              .toList();
        } else if (decoded is String && decoded.trim().isNotEmpty) {
          photoIds = [decoded.trim()];
        }
      } catch (e) {
        log('Error parsing supporting photo IDs: $e');
      }
    }

    return ProjectDelay(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      projectNo: json['project_no']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      siteLiftNo: json['site_lift_no']?.toString() ?? '',
      delayTypeId: json['delay_type_id']?.toString() ?? '',
      delayTypeName: json['delay_type_name']?.toString() ?? '',
      looseTypeId: json['loose_type_id']?.toString() ?? '',
      looseTypeName: json['loose_type_name']?.toString() ?? '',
      responsiblePartyId: json['responsible_party_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      supportingPhotoFileIds: photoIds,
    );
  }

  static List<String> _parseSupportingPhotoIds(dynamic value) {
    if (value == null) {
      return [];
    }

    // API currently returns a String
    if (value is String) {
      if (value.trim().isEmpty) {
        return [];
      }

      try {
        final decoded = jsonDecode(value);

        if (decoded is List) {
          return decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (e) {
        return [];
      }
    }

    // Also support List in case API changes later
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }
}
