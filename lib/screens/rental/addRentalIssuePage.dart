import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/rental/rentalLocationModel.dart';
import 'package:login2/service/service.dart';

class AddRentalIssuePage extends StatefulWidget {
  const AddRentalIssuePage({super.key});

  @override
  State<AddRentalIssuePage> createState() => _AddRentalIssuePageState();
}

class _AddRentalIssuePageState extends State<AddRentalIssuePage> {
  final HttpService _httpService = HttpService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();
  final TextEditingController _advanceAmountController = TextEditingController();
  final TextEditingController _totalPaidAmountController = TextEditingController(text: "0.00");
  final TextEditingController _discountController = TextEditingController(text: "0");
  final TextEditingController _otherExpensesController = TextEditingController(text: "0");
  final TextEditingController _rentIssueIdController = TextEditingController(text: "#RIN");
  final TextEditingController _invoiceNoController = TextEditingController(text: "#");

  // Dropdown values
  String? _selectedCustomerId;
  String? _selectedLocationId;
  String? _selectedPaymentStatus;
  
  // Data lists
  List<CustomerExp> _customers = [];
  List<MaterialData> _materials = [];
  List<RetailLocation> _locations = [];
  List<String> _paymentStatuses = ['Pending', 'Partial', 'Paid'];

  // Product rows
  List<ProductRow> _productRows = [ProductRow()];
  
  // Summary values
  double _totalGrossAmount = 0.0;
  double _gstAmount = 0.0;
  double _grandTotal = 0.0;
  
  // Auto-calculated values
  int _totalDays = 0;
  
  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _invoiceDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _updateTotalDays();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCustomers(),
        _loadMaterials(),
        _loadLocations(),
      ]);
    } catch (e) {
      log('Error loading data: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadCustomers() async {
    final data = await HttpService.getCustomers();
    if (data != null && data.status) {
      setState(() => _customers = data.data);
    }
  }

  Future<void> _loadMaterials() async {
    final data = await _httpService.getMaterials();
    if (data != null && data.status == true && data.data != null) {
      setState(() => _materials = data.data!);
    }
  }

  Future<void> _loadLocations() async {
    final data = await _httpService.getRentalLocation();
    if (data != null && data.status) {
      setState(() => _locations = data.data);
    }
  }

  void _updateTotalDays() {
    if (_fromDateController.text.isNotEmpty && _toDateController.text.isNotEmpty) {
      try {
        final fromDate = DateFormat('dd-MM-yyyy').parse(_fromDateController.text);
        final toDate = DateFormat('dd-MM-yyyy').parse(_toDateController.text);
        final difference = toDate.difference(fromDate).inDays;
        _totalDays = difference >= 0 ? difference + 1 : 0;
        _totalDaysController.text = _totalDays.toString();
        // Update No of Days for all product rows
        for (final row in _productRows) {
          if (row.noOfDaysController.text.isEmpty) {
            row.noOfDaysController.text = _totalDays.toString();
          }
        }
        _recalculateAllRows();
      } catch (e) {
        _totalDaysController.text = "0";
      }
    }
  }

  void _addProductRow() {
    setState(() {
      final newRow = ProductRow();
      newRow.noOfDaysController.text = _totalDays.toString();
      _productRows.add(newRow);
    });
  }

  void _removeProductRow(int index) {
    if (_productRows.length > 1) {
      setState(() {
        _productRows.removeAt(index);
        _recalculateAllRows();
      });
    }
  }

  void _recalculateRow(int index) {
    final row = _productRows[index];
    
    // Parse values
    final quantity = double.tryParse(row.quantityController.text) ?? 0;
    final ratePerDay = double.tryParse(row.ratePerDayController.text) ?? 0;
    final noOfDays = double.tryParse(row.noOfDaysController.text) ?? _totalDays.toDouble();
    
    // Calculate Gross Amount
    final grossAmount = quantity * ratePerDay * noOfDays;
    row.grossAmountController.text = grossAmount.toStringAsFixed(2);
    
    // Calculate GST only if percentage is provided
    double gstAmount = 0;
    if (row.hasGst && row.gstPercentController.text.isNotEmpty) {
      final gstPercent = double.tryParse(row.gstPercentController.text) ?? 0;
      gstAmount = grossAmount * (gstPercent / 100);
    }
    row.gstAmountController.text = gstAmount.toStringAsFixed(2);
    
    // Calculate Total
    final total = grossAmount + gstAmount;
    row.totalController.text = total.toStringAsFixed(2);
    
    _calculateSummary();
  }

  void _recalculateAllRows() {
    for (int i = 0; i < _productRows.length; i++) {
      _recalculateRow(i);
    }
  }

  void _calculateSummary() {
    double totalGross = 0;
    double totalGST = 0;
    
    for (final row in _productRows) {
      totalGross += double.tryParse(row.grossAmountController.text) ?? 0;
      totalGST += double.tryParse(row.gstAmountController.text) ?? 0;
    }
    
    final discount = double.tryParse(_discountController.text) ?? 0;
    final otherExpenses = double.tryParse(_otherExpensesController.text) ?? 0;
    final totalPaid = double.tryParse(_totalPaidAmountController.text) ?? 0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0;
    
    setState(() {
      _totalGrossAmount = totalGross;
      _gstAmount = totalGST;
      _grandTotal = totalGross + totalGST - discount + otherExpenses;
      _totalPaidAmountController.text = (advance + totalPaid).toStringAsFixed(2);
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
      if (controller == _fromDateController || controller == _toDateController) {
        _updateTotalDays();
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      Map<String, dynamic> formData = {
        'token': await Common.getSharedPref('token'),
        'customer_id': _selectedCustomerId,
        'from_date': _fromDateController.text,
        'to_date': _toDateController.text,
        'invoice_date': _invoiceDateController.text,
        'location': _selectedLocationId,
        'total_days': _totalDays.toString(),
        'advance_amount': _advanceAmountController.text,
        'payment_status': _selectedPaymentStatus,
        'total_paid_amount': _totalPaidAmountController.text,
        'discount': _discountController.text,
        'other_expenses': _otherExpensesController.text,
        'grand_total': _grandTotal.toStringAsFixed(2),
        'products': _productRows.where((row) => row.selectedProductId != null).map((row) => {
          'material_id': row.selectedProductId,
          'quantity': row.quantityController.text,
          'rate_per_day': row.ratePerDayController.text,
          'no_of_days': row.noOfDaysController.text,
          'gross_amount': row.grossAmountController.text,
          'gst_percent': row.gstPercentController.text.isNotEmpty ? row.gstPercentController.text : "0",
          'gst_amount': row.gstAmountController.text,
          'total': row.totalController.text,
        }).toList(),
      };
      
      final response = await _httpService.createRentalIssue(formData);
      
      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rental Issue created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to create rental issue'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      log('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // Helper method to check if a product is in stock
  bool _isProductInStock(MaterialData material) {
    if (material.currentStock == null || material.currentStock!.isEmpty) {
      return true; // If stock info is not available, assume it's available
    }
    final stock = double.tryParse(material.currentStock!) ?? 0;
    return stock > 0;
  }

  // Helper method to get stock status text and color
  Map<String, dynamic> _getStockStatus(MaterialData material) {
    if (material.currentStock == null || material.currentStock!.isEmpty) {
      return {'text': 'N/A', 'color': Colors.grey};
    }
    
    final stock = double.tryParse(material.currentStock!) ?? 0;
    if (stock > 0) {
      return {'text': 'Stock: $stock', 'color': Colors.green};
    } else {
      return {'text': 'Out of Stock', 'color': Colors.red};
    }
  }

  Widget _buildProductRow(int index) {
    final row = _productRows[index];
    final isSelectedProductInStock = row.selectedProductId != null 
      ? _materials.firstWhere(
          (m) => m.materialId == row.selectedProductId,
          orElse: () => MaterialData(),
        ).currentStock != null && 
        (double.tryParse(
          _materials.firstWhere(
            (m) => m.materialId == row.selectedProductId,
            orElse: () => MaterialData(currentStock: "0"),
          ).currentStock ?? "0"
        ) ?? 0) > 0
      : true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: !isSelectedProductInStock && row.selectedProductId != null
            ? Colors.grey.shade100
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: !isSelectedProductInStock && row.selectedProductId != null
              ? Colors.red.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory,
                    color: !isSelectedProductInStock && row.selectedProductId != null
                        ? Colors.red
                        : Colors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Product ${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !isSelectedProductInStock && row.selectedProductId != null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                  if (row.currentStock != null && row.currentStock!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStockStatus(
                            _materials.firstWhere(
                              (m) => m.materialId == row.selectedProductId,
                              orElse: () => MaterialData(currentStock: row.currentStock),
                            )
                          )['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStockStatus(
                              _materials.firstWhere(
                                (m) => m.materialId == row.selectedProductId,
                                orElse: () => MaterialData(currentStock: row.currentStock),
                              )
                            )['color'],
                          ),
                        ),
                        child: Text(
                          _getStockStatus(
                            _materials.firstWhere(
                              (m) => m.materialId == row.selectedProductId,
                              orElse: () => MaterialData(currentStock: row.currentStock),
                            )
                          )['text'],
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStockStatus(
                              _materials.firstWhere(
                                (m) => m.materialId == row.selectedProductId,
                                orElse: () => MaterialData(currentStock: row.currentStock),
                              )
                            )['color'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_productRows.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 16),
                  onPressed: () => _removeProductRow(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: row.selectedProductId,
                isExpanded: true,
                hint: const Text('Select Product', style: TextStyle(fontSize: 14)),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                items: _materials.map((material) {
                  final isInStock = _isProductInStock(material);
                  final stockStatus = _getStockStatus(material);
                  return DropdownMenuItem<String>(
                    value: material.materialId,
                    enabled: isInStock,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${material.materialName} (₹${material.unitPrice})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isInStock ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                            if (!isInStock)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (material.currentStock != null && material.currentStock!.isNotEmpty)
                          Text(
                            stockStatus['text'],
                            style: TextStyle(
                              fontSize: 11,
                              color: stockStatus['color'],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final material = _materials.firstWhere(
                    (m) => m.materialId == value,
                    orElse: () => MaterialData(),
                  );
                  if (!_isProductInStock(material)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${material.materialName} is out of stock'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    row.selectedProductId = value;
                    if (material.unitPrice != null) {
                      row.ratePerDayController.text ="";
                      row.unitPriceController.text = material.unitPrice!;
                      row.currentStock = material.currentStock;
                      if (material.gstPercentage != null && material.gstPercentage != "") {
                        row.gstPercentController.text = material.gstPercentage!;
                        row.hasGst = true;
                      } else {
                        row.gstPercentController.text = "";
                        row.hasGst = false;
                      }
                      _recalculateRow(index);
                    }
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Quantity and Unit Price Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quantity', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.quantityController,
                      keyboardType: TextInputType.number,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                      onChanged: (_) => _recalculateRow(index),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        // Check if quantity exceeds available stock
                        if (row.currentStock != null && row.currentStock!.isNotEmpty) {
                          final requestedQty = double.tryParse(value) ?? 0;
                          final availableStock = double.tryParse(row.currentStock!) ?? 0;
                          if (requestedQty > availableStock) {
                            return 'Exceeds available stock ($availableStock)';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.unitPriceController,
                      readOnly: true,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: 'Auto',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Rate and Days Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rate/Day', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.ratePerDayController,
                      keyboardType: TextInputType.number,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                      onChanged: (_) => _recalculateRow(index),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No of Days', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.noOfDaysController,
                      keyboardType: TextInputType.number,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: _totalDays.toString(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                      onChanged: (_) => _recalculateRow(index),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Gross Amount and GST % Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gross Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.grossAmountController,
                      readOnly: true,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('GST %', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        if (!row.hasGst)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('(Optional)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.gstPercentController,
                      keyboardType: TextInputType.number,
                      enabled: row.selectedProductId != null && isSelectedProductInStock && row.hasGst,
                      decoration: InputDecoration(
                        hintText: row.hasGst ? '' : 'Not applicable',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                      onChanged: (_) => _recalculateRow(index),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // GST Amount and Total Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GST Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.gstAmountController,
                      readOnly: true,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.totalController,
                      readOnly: true,
                      enabled: row.selectedProductId != null && isSelectedProductInStock,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: !isSelectedProductInStock,
                        fillColor: !isSelectedProductInStock ? Colors.grey.shade100 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Rental Issue'),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Section
                    _buildSectionCard(
                      title: 'Customer Information',
                      icon: Icons.person,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCustomerId,
                              isExpanded: true,
                              hint: const Text('Select Customer', style: TextStyle(fontSize: 14)),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: _customers.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer.id,
                                  child: Text(customer.name, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedCustomerId = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Dates Section
                    _buildSectionCard(
                      title: 'Rental Dates',
                      icon: Icons.calendar_today,
                      children: [
                        const SizedBox(height: 8),
                        _buildDateField('From Date *', _fromDateController, true),
                        const SizedBox(height: 10),
                        _buildDateField('To Date *', _toDateController, true),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _totalDaysController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Total Days',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calculate, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Invoice Details
                    _buildSectionCard(
                      title: 'Invoice Details',
                      icon: Icons.receipt,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _rentIssueIdController,
                                decoration: InputDecoration(
                                  labelText: 'Rent Issue ID',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.confirmation_number, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _invoiceNoController,
                                decoration: InputDecoration(
                                  labelText: 'Invoice Number',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.numbers, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildDateField('Invoice Date', _invoiceDateController, false),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Location Section
                    _buildSectionCard(
                      title: 'Location',
                      icon: Icons.location_on,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocationId,
                              isExpanded: true,
                              hint: const Text('Select Location', style: TextStyle(fontSize: 14)),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: _locations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location.id,
                                  child: Text(location.locationName, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedLocationId = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Products Section
                    _buildSectionCard(
                      title: 'Products',
                      icon: Icons.shopping_cart,
                      children: [
                        const SizedBox(height: 8),
                        ...List.generate(_productRows.length, (index) {
                          return _buildProductRow(index);
                        }),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _addProductRow,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Row'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Advance Payment
                    _buildSectionCard(
                      title: 'Advance Payment',
                      icon: Icons.payment,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _advanceAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Advance Amount',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.money, size: 20),
                          ),
                          onChanged: (_) => _calculateSummary(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Payment Details
                    _buildSectionCard(
                      title: 'Payment Details',
                      icon: Icons.credit_card,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPaymentStatus,
                              isExpanded: true,
                              hint: const Text('Select Payment Status', style: TextStyle(fontSize: 14)),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: _paymentStatuses.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedPaymentStatus = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _totalPaidAmountController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Total Paid Amount',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Summary Section
                    _buildSectionCard(
                      title: 'Summary',
                      icon: Icons.summarize,
                      children: [
                        const SizedBox(height: 8),
                        _buildSummaryItem('Total Gross Amount', '₹${_totalGrossAmount.toStringAsFixed(2)}'),
                        _buildSummaryItem('GST Amount', '₹${_gstAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Discount',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.discount, size: 20),
                          ),
                          onChanged: (_) => _calculateSummary(),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        TextFormField(
                          controller: _otherExpensesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Other Expenses',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on, size: 20),
                          ),
                          onChanged: (_) => _calculateSummary(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Grand Total
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a86c9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2a86c9)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                              Text(
                                '₹${_grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, bool isRequired) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.calendar_today, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month, size: 18),
          onPressed: () => _selectDate(context, controller),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _invoiceDateController.dispose();
    _totalDaysController.dispose();
    _advanceAmountController.dispose();
    _totalPaidAmountController.dispose();
    _discountController.dispose();
    _otherExpensesController.dispose();
    _rentIssueIdController.dispose();
    _invoiceNoController.dispose();
    super.dispose();
  }
}

class ProductRow {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController ratePerDayController = TextEditingController();
  final TextEditingController noOfDaysController = TextEditingController();
  final TextEditingController grossAmountController = TextEditingController();
  final TextEditingController gstPercentController = TextEditingController();
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  
  String? selectedProductId;
  String? currentStock;
  bool hasGst = false;
  
  ProductRow();
}