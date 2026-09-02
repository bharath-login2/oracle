class SiteDrawingResponse {
  final List<SiteDrawing> data;
  final String message;
  final bool status;

  SiteDrawingResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory SiteDrawingResponse.fromJson(Map<String, dynamic> json) {
    return SiteDrawingResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map(
                (item) => SiteDrawing.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}

class SiteDrawing {
  final String id;
  final String remarks;
  final String fileName;
  final String mediaUrl;
  final String createdAt;
  final String staffName;
  final String workStatus;
  final String unitId;
  final String unitNo;
  final String liftId;
  final String siteLiftName;

  SiteDrawing({
    required this.id,
    required this.remarks,
    required this.fileName,
    required this.mediaUrl,
    required this.createdAt,
    required this.staffName,
    required this.workStatus,
    required this.unitId,
    required this.unitNo,
    required this.liftId,
    required this.siteLiftName,
  });

  factory SiteDrawing.fromJson(Map<String, dynamic> json) {
    return SiteDrawing(
      id: json['id']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      workStatus: json['work_status']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      liftId: json['lift_id']?.toString() ?? '',
      siteLiftName: json['site_lift_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remarks': remarks,
      'file_name': fileName,
      'media_url': mediaUrl,
      'created_at': createdAt,
      'staff_name': staffName,
      'work_status': workStatus,
      'unit_id': unitId,
      'unit_no': unitNo,
      'lift_id': liftId,
      'site_lift_name': siteLiftName,
    };
  }
}
