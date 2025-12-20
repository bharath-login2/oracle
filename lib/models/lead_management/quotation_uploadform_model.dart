import 'dart:io';

class QuotationFormData {
  final String? customerId;
  final String? customerName;
  final String? workOrderId;
  final String? address;
  final String? state;
  final String? district;
  final String? postOffice;
  final String? pincode;
  final String? nationality;
  final String? contactNo;
  final String? emailId;
  final File? quotationFile;
  final String? remarks;

  QuotationFormData({
    this.customerId,
    this.customerName,
    this.workOrderId,
    this.address,
    this.state,
    this.district,
    this.postOffice,
    this.pincode,
    this.nationality,
    this.contactNo,
    this.emailId,
    this.quotationFile,
    this.remarks,
  });

  QuotationFormData copyWith({
    String? customerId,
    String? customerName,
    String? workOrderId,
    String? address,
    String? state,
    String? district,
    String? postOffice,
    String? pincode,
    String? nationality,
    String? contactNo,
    String? emailId,
    File? quotationFile,
    String? remarks,
  }) {
    return QuotationFormData(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      workOrderId: workOrderId ?? this.workOrderId,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      postOffice: postOffice ?? this.postOffice,
      pincode: pincode ?? this.pincode,
      nationality: nationality ?? this.nationality,
      contactNo: contactNo ?? this.contactNo,
      emailId: emailId ?? this.emailId,
      quotationFile: quotationFile ?? this.quotationFile,
      remarks: remarks ?? this.remarks,
    );
  }
}