class AddModuleResponse {
  final bool status;
  final String message;
  final bool data;

  AddModuleResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddModuleResponse.fromJson(Map<String, dynamic> json) {
    return AddModuleResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }

  // Helper method to check if module was added successfully
  bool get isSuccess => status && data;
  
  // Helper method to get appropriate message for UI
  String get displayMessage {
    if (isSuccess) {
      return message.isNotEmpty ? message : 'Module added successfully';
    }
    return message.isNotEmpty ? message : 'Failed to add module';
  }
}

// Extension for additional utilities
extension AddModuleResponseExtension on AddModuleResponse {
  // Convert to a simple result object
  AddModuleResult toResult() {
    return AddModuleResult(
      success: isSuccess,
      message: displayMessage,
    );
  }
}

// Simple result class for easier handling
class AddModuleResult {
  final bool success;
  final String message;

  AddModuleResult({
    required this.success,
    required this.message,
  });
}