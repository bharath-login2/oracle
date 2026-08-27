class ProjectDocumentsResponse {
  final ProjectDocumentsData data;
  final String message;
  final bool status;

  ProjectDocumentsResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ProjectDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentsResponse(
      data: ProjectDocumentsData.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : {},
      ),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}

class ProjectDocumentsData {
  final String projectId;
  final List<ProjectDocument> projectDocs;
  final ProjectDetails projectDetails;
  final String projectNo;

  ProjectDocumentsData({
    required this.projectId,
    required this.projectDocs,
    required this.projectDetails,
    required this.projectNo,
  });

  factory ProjectDocumentsData.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentsData(
      projectId: json['project_id']?.toString() ?? '',
      projectDocs: (json['project_docs'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => ProjectDocument.fromJson(item))
          .toList(),
      projectDetails: ProjectDetails.fromJson(
        json['project_details'] is Map<String, dynamic>
            ? json['project_details'] as Map<String, dynamic>
            : {},
      ),
      projectNo: json['project_no'] is Map
          ? (json['project_no']['project_no']?.toString() ?? '')
          : (json['project_no']?.toString() ?? ''),
    );
  }
}

class ProjectDetails {
  final String id;
  final String projectNo;

  ProjectDetails({
    required this.id,
    required this.projectNo,
  });

  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    return ProjectDetails(
      id: json['id']?.toString() ?? '',
      projectNo: json['project_no']?.toString() ?? '',
    );
  }
}

class ProjectDocument {
  final String id;
  final String projectId;
  final String uploadFile;
  final String title;
  final String unitNo;
  final String siteLiftNo;
  final String remark;
  final String mediaUrl;

  ProjectDocument({
    required this.id,
    required this.projectId,
    required this.uploadFile,
    required this.title,
    required this.unitNo,
    required this.siteLiftNo,
    required this.remark,
    required this.mediaUrl,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      uploadFile: json['upload_file']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      siteLiftNo: json['site_lift_no']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString() ?? '',
    );
  }
}
