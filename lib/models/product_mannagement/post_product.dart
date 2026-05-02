import 'dart:convert';

PostProductModel postProductModelFromJson(String str) {
  try {
    final dynamic jsonData = json.decode(str);
    return PostProductModel.fromJson(jsonData);
  } catch (e) {
    // Handle JSON parsing errors
    return PostProductModel(
      message: "Error parsing response: $e",
      data: false,
      status: false,
    );
  }
}

String postProductModelToJson(PostProductModel data) => json.encode(data.toJson());

class PostProductModel {
  String message;
  dynamic data;
  bool status;

  PostProductModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory PostProductModel.fromJson(dynamic json) {
    if (json == null) {
      return PostProductModel(
        message: "Null response",
        data: null,
        status: false,
      );
    }

    if (json is String) {
      return PostProductModel(
        message: json,
        data: null,
        status: false,
      );
    } else if (json is Map<String, dynamic>) {
      // Handle both associative and numeric-indexed maps
      dynamic statusVal = json["status"] ?? json["0"];
      dynamic messageVal = json["message"] ?? json["1"];
      dynamic dataVal = json["data"] ?? json["2"];

      // Sometimes the status itself is a map if it's like {"0": {"status": true}}
      if (statusVal is Map && statusVal.containsKey("status")) {
        statusVal = statusVal["status"];
      }
      if (messageVal is Map && messageVal.containsKey("message")) {
        messageVal = messageVal["message"];
      }
      if (dataVal is Map && dataVal.containsKey("data")) {
        dataVal = dataVal["data"];
      }

      return PostProductModel(
        message: messageVal?.toString() ?? "",
        data: dataVal,
        status: statusVal == true || statusVal == "true" || statusVal == "success" || statusVal == 1 || statusVal == "1",
      );
    } else if (json is List) {
      if (json.isEmpty) {
        return PostProductModel(
          message: "Empty list response",
          data: null,
          status: false,
        );
      }

      // If it's a list of maps, merge them or find values
      bool status = false;
      String message = "";
      dynamic data;

      for (var item in json) {
        if (item is Map) {
          if (item.containsKey("status")) {
            status = item["status"] == true || item["status"] == "true" || item["status"] == "success" || item["status"] == 1 || item["status"] == "1";
          }
          if (item.containsKey("message")) {
            message = item["message"].toString();
          }
          if (item.containsKey("data")) {
            data = item["data"];
          }
          // Handle numeric keys within the list items if they exist
          if (item.containsKey("0")) {
            var val = item["0"];
             if (val == "status" || (val is Map && val.containsKey("status"))) {
                // This is getting complicated, let's stick to the user's description
             }
          }
        }
      }
      
      // If we couldn't find status in maps, try positional
      if (!status && json.length >= 3) {
         // Fallback for [status, message, data] or similar
         status = json[0] == true || json[0] == "true" || json[0] == 1 || json[0] == "1";
         message = json[1].toString();
         data = json[2];
      }

      return PostProductModel(
        status: status,
        message: message,
        data: data,
      );
    } else {
      return PostProductModel(
        message: "Unexpected response format",
        data: null,
        status: false,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
      };
}