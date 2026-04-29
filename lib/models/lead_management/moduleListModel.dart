class ModuleListResponse {
  final bool status;
  final String message;
  final ModuleListData data;

  ModuleListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ModuleListResponse.fromJson(Map<String, dynamic> json) {
    return ModuleListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ModuleListData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ModuleListData {
  final List<Module> moduleList;

  ModuleListData({
    required this.moduleList,
  });

  factory ModuleListData.fromJson(Map<String, dynamic> json) {
    return ModuleListData(
      moduleList: (json['module_list'] as List<dynamic>?)
              ?.map((item) => Module.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_list': moduleList.map((item) => item.toJson()).toList(),
    };
  }
}

class Module {
  final String moduleId;
  final String module;
  final String projectId;

  Module({
    required this.moduleId,
    required this.module,
    required this.projectId,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      moduleId: json['module_id']?.toString() ?? '',
      module: json['module'] ?? '',
      projectId: json['project_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'module': module,
      'project_id': projectId,
    };
  }
}