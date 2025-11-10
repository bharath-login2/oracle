class PrintInvoiceModel {
  final bool status;
  final String? message;
  final String? pdfUrl;

  PrintInvoiceModel({
    required this.status,
    this.message,
    this.pdfUrl,
  });

  factory PrintInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PrintInvoiceModel(
      status: json['status'] ?? false,
      message: json['message'],
      pdfUrl: json['pdf_url'],
    );
  }
}
