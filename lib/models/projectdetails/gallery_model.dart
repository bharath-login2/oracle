class GalleryResponse {
  final List<GalleryData> data;
  final String message;
  final bool status;

  GalleryResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    return GalleryResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => GalleryData.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class GalleryData {
  final String id;
  final String fileName;
  final String fileType;
  final String mediaUrl;
  final String createdAt;
  final String staffName;
  final String workStatus;
  final String unitId;
  final String unitNo;
  final String liftId;
  final String siteLiftName;

  GalleryData({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.mediaUrl,
    required this.createdAt,
    required this.staffName,
    required this.workStatus,
    required this.unitId,
    required this.unitNo,
    required this.liftId,
    required this.siteLiftName,
  });

  factory GalleryData.fromJson(Map<String, dynamic> json) {
    return GalleryData(
      id: json['id'] ?? '',
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      staffName: json['staff_name'] ?? '',
      workStatus: json['work_status'] ?? '',
      unitId: json['unit_id'] ?? '',
      unitNo: json['unit_no'] ?? '',
      liftId: json['lift_id'] ?? '',
      siteLiftName: json['site_lift_name'] ?? '',
    );
  }
}