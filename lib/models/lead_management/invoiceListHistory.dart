import 'dart:convert';

InvoiceHistoryLogModel invoiceHistoryLogModelFromJson(String str) =>
    InvoiceHistoryLogModel.fromJson(json.decode(str));

String invoiceHistoryLogModelToJson(InvoiceHistoryLogModel data) =>
    json.encode(data.toJson());

class InvoiceHistoryLogModel {
  List<InvoiceLogData>? data;
  bool? status;
  String? message;

  InvoiceHistoryLogModel({
    this.data,
    this.status,
    this.message,
  });

  factory InvoiceHistoryLogModel.fromJson(Map<String, dynamic> json) =>
      InvoiceHistoryLogModel(
        data: json["data"] == null
            ? []
            : List<InvoiceLogData>.from(
                json["data"]!.map((x) => InvoiceLogData.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class InvoiceLogData {
  String? rowId;
  String? logData;
  String? createdAt;
  String? staffName;
  String? proPicThumb;

  InvoiceLogData({
    this.rowId,
    this.logData,
    this.createdAt,
    this.staffName,
    this.proPicThumb,
  });

  factory InvoiceLogData.fromJson(Map<String, dynamic> json) => InvoiceLogData(
        rowId: json["row_id"],
        logData: json["log_data"],
        createdAt: json["created_at"],
        staffName: json["staff_name"],
        proPicThumb: json["pro_pic_thumb"],
      );

  Map<String, dynamic> toJson() => {
        "row_id": rowId,
        "log_data": logData,
        "created_at": createdAt,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
      };
}
