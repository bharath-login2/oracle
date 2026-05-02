class OpeningStockItem {
  final String productId;
  final String productName;
  final String unit;
  int quantity;
  double unitPrice;
  String description;

  OpeningStockItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    this.description = "",
  });

  double get totalAmount => quantity * unitPrice;
}
