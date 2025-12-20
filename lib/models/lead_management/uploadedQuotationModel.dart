// models/lead_management/uploaded_quotation_model.dart
import 'dart:convert';

class UploadedQuotationModel {
  final String status;
  final UploadedQuotationModeData data;

  UploadedQuotationModel({
    required this.status,
    required this.data,
  });

  factory UploadedQuotationModel.fromRawJson(String str) =>
      UploadedQuotationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadedQuotationModel.fromJson(Map<String, dynamic> json) =>
      UploadedQuotationModel(
        status: json["status"] ?? "",
        data: UploadedQuotationModeData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class UploadedQuotationModeData {
  final String id;
  final String quoteId;
  final String customerId;
  final String workorderId;
  final String enquiryDate;
  final String approvalStatus;
  final String createdBy;
  final String address;
  final String district;
  final String state;
  final String companyId;
  final String createdAt;
  final String status;
  final String type;
  final String file;
  final String requestId;
  final String deletedDatetime;
  final String qtePk;
  final String userName;
  final String customerName;
 final String totalAmount;
  UploadedQuotationModeData({
    required this.id,
    required this.quoteId,
    required this.customerId,
    required this.workorderId,
    required this.enquiryDate,
    required this.approvalStatus,
    required this.createdBy,
    required this.address,
    required this.district,
    required this.state,
    required this.companyId,
    required this.createdAt,
    required this.status,
    required this.type,
    required this.file,
    required this.requestId,
    required this.deletedDatetime,
    required this.qtePk,
    required this.userName,
    required this.customerName,
      required this.totalAmount,
  });

  factory UploadedQuotationModeData.fromRawJson(String str) =>
      UploadedQuotationModeData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadedQuotationModeData.fromJson(Map<String, dynamic> json) =>
      UploadedQuotationModeData(
        id: json["id"]?.toString() ?? "",
        quoteId: json["quote_id"]?.toString() ?? "",
        customerId: json["customer_id"]?.toString() ?? "",
        workorderId: json["workorder_id"]?.toString() ?? "",
        enquiryDate: json["enquiry_date"]?.toString() ?? "",
        approvalStatus: json["approval_status"]?.toString() ?? "",
        createdBy: json["created_by"]?.toString() ?? "",
        address: json["address"]?.toString() ?? "",
        district: json["district"]?.toString() ?? "",
        state: json["state"]?.toString() ?? "",
        companyId: json["company_id"]?.toString() ?? "",
        createdAt: json["created_at"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "",
        type: json["type"]?.toString() ?? "",
        file: json["file"]?.toString() ?? "",
        requestId: json["request_id"]?.toString() ?? "",
        deletedDatetime: json["deleted_datetime"]?.toString() ?? "",
        qtePk: json["qte_pk"]?.toString() ?? "",
        userName: json["user_name"]?.toString() ?? "",
        customerName: json["customer_name"]?.toString() ?? "",
          totalAmount: json["total_amount"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quote_id": quoteId,
        "customer_id": customerId,
        "workorder_id": workorderId,
        "enquiry_date": enquiryDate,
        "approval_status": approvalStatus,
        "created_by": createdBy,
        "address": address,
        "district": district,
        "state": state,
        "company_id": companyId,
        "created_at": createdAt,
        "status": status,
        "type": type,
        "file": file,
        "request_id": requestId,
        "deleted_datetime": deletedDatetime,
        "qte_pk": qtePk,
        "user_name": userName,
        "customer_name": customerName,
         "total_amount": totalAmount,
      };
}