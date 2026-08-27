class ProjectDocumentUnitResponse {
  final List<ProjectDocumentUnit> data;
  final String message;
  final bool status;

  ProjectDocumentUnitResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ProjectDocumentUnitResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProjectDocumentUnitResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => ProjectDocumentUnit.fromJson(item))
          .toList(),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class ProjectDocumentUnit {
  final String id;
  final String unitNo;

  ProjectDocumentUnit({
    required this.id,
    required this.unitNo,
  });

  factory ProjectDocumentUnit.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProjectDocumentUnit(
      id: json['id'] ?? '',
      unitNo: json['unit_no'] ?? '',
    );
  }
}