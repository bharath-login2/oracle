import 'dart:convert';

CheckBarcodeDuplicateModel checkBarcodeDuplicateModelFromJson(String str) =>
    CheckBarcodeDuplicateModel.fromJson(json.decode(str));

class CheckBarcodeDuplicateModel {
  bool? status;
  bool? duplicate;
  String? message;

  CheckBarcodeDuplicateModel({
    this.status,
    this.duplicate,
    this.message,
  });

  factory CheckBarcodeDuplicateModel.fromJson(
      Map<String, dynamic> json) {
    return CheckBarcodeDuplicateModel(
      status: json['status'].toString().toLowerCase() == 'true',
      duplicate: json['duplicate'].toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'duplicate': duplicate,
      'message': message,
    };
  }
}