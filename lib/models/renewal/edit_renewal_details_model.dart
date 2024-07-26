// To parse this JSON data, do
//
//     final editRenewalDetailsModel = editRenewalDetailsModelFromJson(jsonString);

import 'dart:convert';

EditRenewalDetailsModel editRenewalDetailsModelFromJson(String str) => EditRenewalDetailsModel.fromJson(json.decode(str));

String editRenewalDetailsModelToJson(EditRenewalDetailsModel data) => json.encode(data.toJson());

class EditRenewalDetailsModel {
    Data data;
    bool status;
    String message;

    EditRenewalDetailsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory EditRenewalDetailsModel.fromJson(Map<String, dynamic> json) => EditRenewalDetailsModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
    };
}

class Data {
    String uniId;
    String renewalType;
    String renewalId;
    String invoicelId;
    String cartId;
    String clientId;
    DateTime startDate;
    DateTime endDate;
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
    List<InvoiceList> invoiceLists;
    List<PaymentStatusList> paymentStatusList;
    List<Customer> paymentMethods;
    List<RenewalTemplate> renewalTemplate;
    List<Customer> customers;
    List<AllProduct> allProducts;
    List<dynamic> branch;
    List<Staff> staff;

    Data({
        required this.uniId,
        required this.renewalType,
        required this.renewalId,
        required this.invoicelId,
        required this.cartId,
        required this.clientId,
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
        required this.paymentStatusList,
        required this.paymentMethods,
        required this.renewalTemplate,
        required this.customers,
        required this.allProducts,
        required this.branch,
        required this.staff,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        uniId: json["uni_id"],
        renewalType: json["renewal_type"],
        renewalId: json["renewal_id"],
        invoicelId: json["invoicel_id"],
        cartId: json["cart_id"],
        clientId: json["client_id"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        templateId: json["template_id"],
        branchId: json["branch_id"],
        remarks: json["remarks"],
        slNumber: json["sl_number"],
        displayInvoice: json["display_invoice"],
        invoiceNumber: json["invoice_number"],
        invoiceDate: json["invoice_date"],
        totalAmount: json["total_amount"],
        subTotal: json["sub_total"],
        estimatedTax: json["estimated_tax"],
        discountAmount: json["discount_amount"],
        shippingAmount: json["shipping_amount"],
        paymentStatus: json["payment_status"],
        receiptCount: json["receipt_count"],
        paidAmount: json["paid_amount"],
        invoiceLists: List<InvoiceList>.from(json["invoice_lists"].map((x) => InvoiceList.fromJson(x))),
        paymentStatusList: List<PaymentStatusList>.from(json["payment_status_list"].map((x) => PaymentStatusList.fromJson(x))),
        paymentMethods: List<Customer>.from(json["payment_methods"].map((x) => Customer.fromJson(x))),
        renewalTemplate: List<RenewalTemplate>.from(json["renewal_template"].map((x) => RenewalTemplate.fromJson(x))),
        customers: List<Customer>.from(json["customers"].map((x) => Customer.fromJson(x))),
        allProducts: List<AllProduct>.from(json["all_products"].map((x) => AllProduct.fromJson(x))),
        branch: List<dynamic>.from(json["branch"].map((x) => x)),
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "uni_id": uniId,
        "renewal_type": renewalType,
        "renewal_id": renewalId,
        "invoicel_id": invoicelId,
        "cart_id": cartId,
        "client_id": clientId,
        "start_date": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "template_id": templateId,
        "branch_id": branchId,
        "remarks": remarks,
        "sl_number": slNumber,
        "display_invoice": displayInvoice,
        "invoice_number": invoiceNumber,
        "invoice_date": invoiceDate,
        "total_amount": totalAmount,
        "sub_total": subTotal,
        "estimated_tax": estimatedTax,
        "discount_amount": discountAmount,
        "shipping_amount": shippingAmount,
        "payment_status": paymentStatus,
        "receipt_count": receiptCount,
        "paid_amount": paidAmount,
        "invoice_lists": List<dynamic>.from(invoiceLists.map((x) => x.toJson())),
        "payment_status_list": List<dynamic>.from(paymentStatusList.map((x) => x.toJson())),
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "renewal_template": List<dynamic>.from(renewalTemplate.map((x) => x.toJson())),
        "customers": List<dynamic>.from(customers.map((x) => x.toJson())),
        "all_products": List<dynamic>.from(allProducts.map((x) => x.toJson())),
        "branch": List<dynamic>.from(branch.map((x) => x)),
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
    };
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
        id: json["id"],
        productName: json["product_name"],
        sellingPrice: json["selling_price"],
        taxPercent: json["tax_percent"],
        noOfDays: json["no_of_days"],
        taxAmount: json["tax_amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "selling_price": sellingPrice,
        "tax_percent": taxPercent,
        "no_of_days": noOfDays,
        "tax_amount": taxAmount,
    };
}

class Customer {
    String id;
    String name;

    Customer({
        required this.id,
        required this.name,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
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
        rowId: json["row_id"],
        productId: json["product_id"],
        productName: json["product_name"],
        productDescription: json["product_description"],
        rate: json["rate"],
        qty: json["qty"],
        taxPercentage: json["tax_percentage"],
        taxAmount: json["tax_amount"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "row_id": rowId,
        "product_id": productId,
        "product_name": productName,
        "product_description": productDescription,
        "rate": rate,
        "qty": qty,
        "tax_percentage": taxPercentage,
        "tax_amount": taxAmount,
        "amount": amount,
    };
}

class PaymentStatusList {
    String paymentStatus;
    String displaySts;

    PaymentStatusList({
        required this.paymentStatus,
        required this.displaySts,
    });

    factory PaymentStatusList.fromJson(Map<String, dynamic> json) => PaymentStatusList(
        paymentStatus: json["payment_status"],
        displaySts: json["display_sts"],
    );

    Map<String, dynamic> toJson() => {
        "payment_status": paymentStatus,
        "display_sts": displaySts,
    };
}

class RenewalTemplate {
    String id;
    String templateName;

    RenewalTemplate({
        required this.id,
        required this.templateName,
    });

    factory RenewalTemplate.fromJson(Map<String, dynamic> json) => RenewalTemplate(
        id: json["id"],
        templateName: json["template_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_name": templateName,
    };
}

class Staff {
    String userId;
    String staffName;

    Staff({
        required this.userId,
        required this.staffName,
    });

    factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        userId: json["user_id"],
        staffName: json["staff_name"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
    };
}
