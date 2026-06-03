class SupplierDetailsResponse {
  bool? status;
  String? message;
  List<SupplierData>? data;

  SupplierDetailsResponse({
    this.status,
    this.message,
    this.data,
  });

  SupplierDetailsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SupplierData>[];
      json['data'].forEach((v) {
        data!.add(SupplierData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SupplierData {
  String? id;
  String? materialId;
  String? supplierName;
  String? contactPerson;
  String? contactNo;
  String? address;
  String? adharNo;
  String? gstNo;
  String? accNo;
  String? ifscCode;
  String? beneficiaryName;
  String? openingBalance;
  String? balanceAmt;
  String? companyId;
   String? supplierType;

  SupplierData({
    this.id,
    this.materialId,
    this.supplierName,
    this.contactPerson,
    this.contactNo,
    this.address,
    this.adharNo,
    this.gstNo,
    this.accNo,
    this.ifscCode,
    this.beneficiaryName,
    this.openingBalance,
    this.balanceAmt,
    this.companyId,
    this.supplierType,
  });

  SupplierData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    materialId = json['material_id'];
    supplierName = json['supplier_name'];
    contactPerson = json['contact_person'];
    contactNo = json['contact_no'];
    address = json['address'];
    adharNo = json['adhar_no'];
    gstNo = json['gst_no'];
    accNo = json['acc_no'];
    ifscCode = json['ifsc_code'];
    beneficiaryName = json['beneficiary_name'];
    openingBalance = json['opening_balance']?.toString();
    balanceAmt = json['balance_amt']?.toString();
    companyId = json['company_id']?.toString();
    supplierType = json['supplier_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['material_id'] = materialId;
    data['supplier_name'] = supplierName;
    data['contact_person'] = contactPerson;
    data['contact_no'] = contactNo;
    data['address'] = address;
    data['adhar_no'] = adharNo;
    data['gst_no'] = gstNo;
    data['acc_no'] = accNo;
    data['ifsc_code'] = ifscCode;
    data['beneficiary_name'] = beneficiaryName;
    data['opening_balance'] = openingBalance;
    data['balance_amt'] = balanceAmt;
    data['company_id'] = companyId;
    data['supplier_type'] = supplierType;
    return data;
  }


}