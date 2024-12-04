// To parse this JSON data, do
//
//     final editRenewalDetailsModel = editRenewalDetailsModelFromJson(jsonString);

import 'dart:convert';

RenewalByIdModel renewalByIdModelFromJson(String str) =>
    RenewalByIdModel.fromJson(json.decode(str));

class RenewalByIdModel {
  Data data;
  bool status;
  String message;

  RenewalByIdModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory RenewalByIdModel.fromJson(Map<String, dynamic> json) =>
      RenewalByIdModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );
}

class Data {
  String uniId;
  String renewalType;
  String renewalId;
  String invoicelId;
  String cartId;
  String clientId;
  String customerName;
  DateTime startDate;
  DateTime endDate;
  String nextStartDate;
  String nextEndDate;
  String noOfDays;
  String templateId;
  String branchId;
  String remarks;
  String slNumber;
  String displayInvoice;
  String invoiceNumber;
  String invoiceDate;
  String totalAmount;
  String subTotal;
  String estimatedTax;
  String discountAmount;
  String shippingAmount;
  String paymentStatus;
  String receiptCount;
  String paidAmount;
  String paymentMethod;
  String templateName;
  bool createInvoice;
  bool createReceipt;
  bool isInvoiceCreated;
  List<InvoiceList> invoiceLists;
  List<NextRenewalDetail> nextRenewalDetails;
  List<PaymentStatusList> paymentStatusList;
  List<Customer> paymentMethods;
  List<RenewalTemplate> renewalTemplate;
  List<Customer> customers;
  List<AllProduct> allProducts;
  List<dynamic> branch;
  List<Staff> staff;
  List<TargetGroup> targetGroups;

  Data({
    required this.uniId,
    required this.renewalType,
    required this.renewalId,
    required this.invoicelId,
    required this.cartId,
    required this.clientId,
    required this.customerName,
    required this.startDate,
    required this.endDate,
    required this.templateId,
    required this.branchId,
    required this.remarks,
    required this.slNumber,
    required this.displayInvoice,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.totalAmount,
    required this.subTotal,
    required this.estimatedTax,
    required this.discountAmount,
    required this.shippingAmount,
    required this.paymentStatus,
    required this.receiptCount,
    required this.paidAmount,
    required this.invoiceLists,
    required this.nextRenewalDetails,
    required this.paymentStatusList,
    required this.paymentMethods,
    required this.renewalTemplate,
    required this.customers,
    required this.allProducts,
    required this.branch,
    required this.staff,
    required this.paymentMethod,
    required this.templateName,
    required this.createInvoice,
    required this.createReceipt,
    required this.isInvoiceCreated,
    required this.nextStartDate,
    required this.nextEndDate,
    required this.noOfDays,
    required this.targetGroups,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        uniId: json["uni_id"] ?? "",
        renewalType: json["renewal_type"] ?? "",
        renewalId: json["renewal_id"] ?? "",
        invoicelId: json["invoicel_id"] ?? "",
        cartId: json["cart_id"] ?? "",
        clientId: json["client_id"] ?? "",
        customerName: json["customer_name"] ?? "",
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        templateId: json["template_id"] ?? "",
        nextStartDate: json["next_start_date"] ?? "",
        nextEndDate: json["next_end_date"] ?? "",
        noOfDays: json["no_of_days"] ?? "",
        branchId: json["branch_id"] ?? "",
        remarks: json["remarks"] ?? "",
        slNumber: json["sl_number"] ?? "",
        displayInvoice: json["display_invoice"] ?? "",
        invoiceNumber: json["invoice_number"] ?? "",
        invoiceDate: json["invoice_date"] ?? "",
        totalAmount: json["total_amount"] ?? "",
        subTotal: json["sub_total"] ?? "",
        estimatedTax: json["estimated_tax"] ?? "",
        discountAmount: json["discount_amount"] ?? "",
        shippingAmount: json["shipping_amount"] ?? "",
        paymentStatus: json["payment_status"] ?? "",
        receiptCount: json["receipt_count"] ?? "",
        paidAmount: json["paid_amount"] ?? "",
        paymentMethod: json["payment_method"] ?? "",
        templateName: json["template_name"] ?? "",
        createInvoice: json["create_invoice"] ?? false,
        createReceipt: json["create_receipt"] ?? false,
        isInvoiceCreated: json["is_invoice_created"] ?? false,
        invoiceLists: List<InvoiceList>.from(
            json["invoice_lists"].map((x) => InvoiceList.fromJson(x))),
        nextRenewalDetails: List<NextRenewalDetail>.from(
            json["next_renewal_details"]
                .map((x) => NextRenewalDetail.fromJson(x))),
        paymentStatusList: List<PaymentStatusList>.from(
            json["payment_status_list"]
                .map((x) => PaymentStatusList.fromJson(x))),
        paymentMethods: List<Customer>.from(
            json["payment_methods"].map((x) => Customer.fromJson(x))),
        renewalTemplate: List<RenewalTemplate>.from(
            json["renewal_template"].map((x) => RenewalTemplate.fromJson(x))),
        customers: List<Customer>.from(
            json["customers"].map((x) => Customer.fromJson(x))),
        allProducts: List<AllProduct>.from(
            json["all_products"].map((x) => AllProduct.fromJson(x))),
        branch: List<dynamic>.from(json["branch"].map((x) => x)),
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        targetGroups: List<TargetGroup>.from(json["target_groups"].map((x) => TargetGroup.fromJson(x))),
      );
}

class AllProduct {
  String id;
  String productName;
  String sellingPrice;
  String taxPercent;
  String noOfDays;
  String taxAmount;

  AllProduct({
    required this.id,
    required this.productName,
    required this.sellingPrice,
    required this.taxPercent,
    required this.noOfDays,
    required this.taxAmount,
  });

  factory AllProduct.fromJson(Map<String, dynamic> json) => AllProduct(
        id: json["id"] ?? "",
        productName: json["product_name"] ?? "",
        sellingPrice: json["selling_price"] ?? "",
        taxPercent: json["tax_percent"] ?? "",
        noOfDays: json["no_of_days"] ?? "",
        taxAmount: json["tax_amount"] ?? "",
      );
}

class Customer {
  String id;
  String name;

  Customer({
    required this.id,
    required this.name,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
      );
}

class InvoiceList {
  String rowId;
  String productId;
  String productName;
  String productDescription;
  String rate;
  String qty;
  String taxPercentage;
  String taxAmount;
  String amount;

  InvoiceList({
    required this.rowId,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.rate,
    required this.qty,
    required this.taxPercentage,
    required this.taxAmount,
    required this.amount,
  });

  factory InvoiceList.fromJson(Map<String, dynamic> json) => InvoiceList(
        rowId: json["row_id"] ?? "",
        productId: json["product_id"] ?? "",
        productName: json["product_name"] ?? "",
        productDescription: json["product_description"] ?? "",
        rate: json["rate"] ?? "",
        qty: json["qty"] ?? "",
        taxPercentage: json["tax_percentage"] ?? "0",
        taxAmount: json["tax_amount"] ?? "0",
        amount: json["amount"] ?? "",
      );
}

class NextRenewalDetail {
  String nextRowId;
  String nextPrdId;
  String nextPrdName;
  String nextPrdDescription;
  String nextPrdRate;
  String nextPrdQty;
  String nextPrdTaxPc;
  String nextPrdTaxAmount;
  String nextPrdAmount;

  NextRenewalDetail({
    required this.nextRowId,
    required this.nextPrdId,
    required this.nextPrdName,
    required this.nextPrdDescription,
    required this.nextPrdRate,
    required this.nextPrdQty,
    required this.nextPrdTaxPc,
    required this.nextPrdTaxAmount,
    required this.nextPrdAmount,
  });

  factory NextRenewalDetail.fromJson(Map<String, dynamic> json) =>
      NextRenewalDetail(
        nextRowId: json["next_row_id"],
        nextPrdId: json["next_prd_id"],
        nextPrdName: json["next_prd_name"],
        nextPrdDescription: json["next_prd_description"],
        nextPrdRate: json["next_prd_rate"],
        nextPrdQty: json["next_prd_qty"],
        nextPrdTaxPc: json["next_prd_tax_pc"],
        nextPrdTaxAmount: json["next_prd_tax_amount"],
        nextPrdAmount: json["next_prd_amount"],
      );
}

class PaymentStatusList {
  String paymentStatus;
  String displaySts;

  PaymentStatusList({
    required this.paymentStatus,
    required this.displaySts,
  });

  factory PaymentStatusList.fromJson(Map<String, dynamic> json) =>
      PaymentStatusList(
        paymentStatus: json["payment_status"] ?? "",
        displaySts: json["display_sts"] ?? "",
      );
}

class RenewalTemplate {
  String id;
  String templateName;

  RenewalTemplate({
    required this.id,
    required this.templateName,
  });

  factory RenewalTemplate.fromJson(Map<String, dynamic> json) =>
      RenewalTemplate(
        id: json["id"] ?? "",
        templateName: json["template_name"] ?? "",
      );
}

class Staff {
  String userId;
  String staffName;

  Staff({
    required this.userId,
    required this.staffName,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        userId: json["user_id"] ?? "",
        staffName: json["staff_name"] ?? "",
      );
}
class TargetGroup {
    String id;
    String groupName;

    TargetGroup({
        required this.id,
        required this.groupName,
    });

    factory TargetGroup.fromJson(Map<String, dynamic> json) => TargetGroup(
        id: json["id"],
        groupName: json["group_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "group_name": groupName,
    };
}