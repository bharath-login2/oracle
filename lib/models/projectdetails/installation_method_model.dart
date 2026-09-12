class InstallationMethodItem {
  final String methodId;
  final String methodName;

  const InstallationMethodItem({
    required this.methodId,
    required this.methodName,
  });

  factory InstallationMethodItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return InstallationMethodItem(
      methodId: json['method_id']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
    );
  }
}

class InstallationMethodResponse {
  final List<InstallationMethodItem> data;
  final String message;
  final bool status;

  const InstallationMethodResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory InstallationMethodResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return InstallationMethodResponse(
      data: (json['data'] as List? ?? [])
          .map(
            (item) => InstallationMethodItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}
