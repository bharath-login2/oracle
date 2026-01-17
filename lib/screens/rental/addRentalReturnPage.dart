import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/rental/rentalLocationModel.dart';
import 'package:login2/service/service.dart';

class AddRentalReturnPage extends StatefulWidget {
  const AddRentalReturnPage({super.key});

  @override
  State<AddRentalReturnPage> createState() => _AddRentalReturnPageState();
}

class _AddRentalReturnPageState extends State<AddRentalReturnPage> {
  final HttpService _httpService = HttpService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _otherExpensesController = TextEditingController(text: "0");
  final TextEditingController _rentReturnIdController = TextEditingController(text: "#RRN");
  final TextEditingController _invoiceNoController = TextEditingController(text: "#");
  String? _selectedCustomerId;
  String? _selectedLocationId;
  List<CustomerExp> _customers = [];
  List<MaterialData> _materials = [];
  List<RetailLocation> _locations = [];
  List<RentalIssueItem> _rentalIssues = [];
  List<RentalReturnRow> _productRows = [RentalReturnRow()];
  double _grandTotal = 0.0;
  double _invoiceAmount = 0.0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _loadData();
    _returnDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _invoiceDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCustomers(),
        _loadMaterials(),
        _loadLocations(),
        _loadRentalIssues(),
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

  Future<void> _loadRentalIssues() async {
    // Implement this method to fetch rental issues for the selected customer
    // Example: final data = await _httpService.getRentalIssues();
    // if (data != null && data.status) {
    //   setState(() => _rentalIssues = data.data);
    // }
  }

  void _addProductRow() {
    setState(() {
      _productRows.add(RentalReturnRow());
    });
  }

  void _removeProductRow(int index) {
    if (_productRows.length > 1) {
      setState(() {
        _productRows.removeAt(index);
        _calculateSummary();
      });
    }
  }

  void _recalculateRow(int index) {
    final row = _productRows[index];
    final quantity = double.tryParse(row.quantityController.text) ?? 0;
    final ratePerDay = double.tryParse(row.ratePerDayController.text) ?? 0;
    final noOfDays = double.tryParse(row.noOfDaysController.text) ?? 0;
    final grossAmount = quantity * ratePerDay * noOfDays;
    row.grossAmountController.text = grossAmount.toStringAsFixed(2);
    final gstPercent = double.tryParse(row.gstPercentController.text) ?? 0;
    final gstAmount = grossAmount * (gstPercent / 100);
    row.gstAmountController.text = gstAmount.toStringAsFixed(2);
    final total = grossAmount + gstAmount;
    row.totalController.text = total.toStringAsFixed(2);
    _calculateSummary();
  }

  void _calculateSummary() {
    double totalAmount = 0;
    for (final row in _productRows) {
      totalAmount += double.tryParse(row.totalController.text) ?? 0;
    }
    final otherExpenses = double.tryParse(_otherExpensesController.text) ?? 0;
    setState(() {
      _grandTotal = totalAmount;
      _invoiceAmount = totalAmount + otherExpenses;
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
        'return_date': _returnDateController.text,
        'invoice_date': _invoiceDateController.text,
        'location': _selectedLocationId,
        'other_expenses': _otherExpensesController.text,
        'grand_total': _grandTotal.toStringAsFixed(2),
        'invoice_amount': _invoiceAmount.toStringAsFixed(2),
        'products': _productRows.where((row) => row.selectedProductId != null).map((row) => {
          'material_id': row.selectedProductId,
          'quantity': row.quantityController.text,
          'rate_per_day': row.ratePerDayController.text,
          'no_of_days': row.noOfDaysController.text,
          'gross_amount': row.grossAmountController.text,
          'gst_percent': row.gstPercentController.text,
          'gst_amount': row.gstAmountController.text,
          'total': row.totalController.text,
          'returning': row.isReturning ? '1' : '0',
          'damaged': row.isDamaged ? '1' : '0',
        }).toList(),
      };
      
      final response = await _httpService.createRentalReturn(formData);
      
      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rental Return created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to create rental return'),
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

  Widget _buildProductRow(int index) {
    final row = _productRows[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Product ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
          
          // Product Dropdown
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
                  return DropdownMenuItem<String>(
                    value: material.materialId,
                    child: Text(
                      '${material.materialName} (₹${material.unitPrice})',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    row.selectedProductId = value;
                    if (value != null) {
                      final material = _materials.firstWhere(
                        (m) => m.materialId == value,
                        orElse: () => MaterialData(),
                      );
                      if (material.unitPrice != null) {
                        row.ratePerDayController.text = material.unitPrice!;
                        _recalculateRow(index);
                      }
                    }
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Quantity and Rate/Day Row
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
                      decoration: InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
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
                    const Text('Rate/Day', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.ratePerDayController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
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
            ],
          ),
          
          const SizedBox(height: 10),
          
          // No of Days and Gross Amount Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No of days', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.noOfDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
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
                    const Text('Gross Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.grossAmountController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // GST % and GST Amount Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GST %', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.gstPercentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '18',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (_) => _recalculateRow(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GST Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.gstAmountController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Checkboxes for Returning and Damaged
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: row.isReturning,
                      onChanged: (value) {
                        setState(() {
                          row.isReturning = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF2a86c9),
                    ),
                    const Text('Returning', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: row.isDamaged,
                      onChanged: (value) {
                        setState(() {
                          row.isDamaged = value ?? false;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    const Text('Damaged', style: TextStyle(fontSize: 14, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              TextFormField(
                controller: row.totalController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '0.00',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
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
        title: const Text('Add Rental Return'),
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
                    
                    _buildSectionCard(
                      title: 'Customer *',
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
                                // Load rental issues for this customer
                                if (value != null) {
                                  _loadRentalIssues();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.now())),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Issued Date',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    // ID Section
                    _buildSectionCard(
                      title: 'Rent Return ID',
                      icon: Icons.confirmation_number,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _rentReturnIdController,
                          decoration: InputDecoration(
                            hintText: '#RRN001',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.numbers, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    // Location and Return Date
                    _buildSectionCard(
                      title: 'Location & Dates',
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
                        const SizedBox(height: 10),
                        _buildDateField('Returning Date *', _returnDateController, true),
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
                        TextFormField(
                          controller: _invoiceNoController,
                          decoration: InputDecoration(
                            labelText: 'Invoice Number',
                            hintText: 'Invoice',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.numbers, size: 20),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDateField('Invoice Date', _invoiceDateController, false),
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
                            label: const Text('Add Product'),
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

                    // Summary Section
                    _buildSectionCard(
                      title: 'Summary',
                      icon: Icons.summarize,
                      children: [
                        const SizedBox(height: 8),
                        // Grand Total
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${_grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Other Expenses
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
                        
                        const SizedBox(height: 10),
                        
                        // Invoice Amount
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
                                'Invoice Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                              Text(
                                '₹${_invoiceAmount.toStringAsFixed(2)}',
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

  @override
  void dispose() {
    _returnDateController.dispose();
    _invoiceDateController.dispose();
    _otherExpensesController.dispose();
    _rentReturnIdController.dispose();
    _invoiceNoController.dispose();
    super.dispose();
  }
}

class RentalReturnRow {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController ratePerDayController = TextEditingController();
  final TextEditingController noOfDaysController = TextEditingController();
  final TextEditingController grossAmountController = TextEditingController();
  final TextEditingController gstPercentController = TextEditingController(text: "18");
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  
  String? selectedProductId;
  bool isReturning = true;
  bool isDamaged = false;
  
  RentalReturnRow();
}

// Model for rental issue items (you might need to create this)
class RentalIssueItem {
  final String? id;
  final String? productName;
  final String? quantity;
  final String? rate;

  RentalIssueItem({this.id, this.productName, this.quantity, this.rate});
}

