// FileUploadResponse Model
class FileUploadResponse {
  final bool status;
  final String message;
  final String? data; 
  final Map<String, dynamic>? errorDetails;

  FileUploadResponse({
    required this.status,
    required this.message,
    this.data,
    this.errorDetails,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errorDetails: json['error_details'],
    );
  }
}

class BookingResponse {
  final bool status;
  final String message;
  final String? bookingId;
  final String? invoiceNumber;
  final Map<String, dynamic>? errorDetails;

  BookingResponse({
    required this.status,
    required this.message,
    this.bookingId,
    this.invoiceNumber,
    this.errorDetails,
  });
  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      bookingId: json['booking_id'],
      invoiceNumber: json['invoice_number'],
      errorDetails: json['error_details'],
    );
  }
}