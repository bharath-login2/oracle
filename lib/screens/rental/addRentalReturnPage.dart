import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';

import 'package:login2/models/rental/rentalCustomerLocations.dart';
import 'package:login2/models/rental/rentIdByCustomerReturnModel.dart';
import 'package:login2/models/rental/rentalCollectedByStaffList.dart';
import 'package:login2/models/rental/returnDetailsRentalModel.dart';
import 'package:login2/service/service.dart';

class AddRentalReturnPage extends StatefulWidget {
  final String? customerId;
  final String? customerName;
  final String? locationId;
  final String? rentId;

  const AddRentalReturnPage({
    super.key,
    this.customerId,
    this.customerName,
    this.locationId,
    this.rentId,
  });

  @override
  State<AddRentalReturnPage> createState() => _AddRentalReturnPageState();
}

class _AddRentalReturnPageState extends State<AddRentalReturnPage> {
  final HttpService _httpService = HttpService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _otherExpensesController =
      TextEditingController(text: "0");
  final TextEditingController _rentReturnIdController =
      TextEditingController(text: "#RRN");
  final TextEditingController _invoiceNoController =
      TextEditingController(text: "#");
  String? _selectedCustomerId;
  String? _selectedCustomerName = "Select Customer";
  String? _selectedLocationId;
  List<CustomerExp> _customers = [];
  List<LocationData> _locations = [];
  List<RentIssueItem> _rentalIssues = [];
  List<RentalReturnRow> _productRows = [RentalReturnRow()];
  List<Staff> _customerStaff = [];

  String? _selectedRentId;
  String? _selectedStaffId;
  String? _selectedPaymentStatus = 'Unpaid';
  String? _selectedPaymentMethod = 'Cash';
  String? _paymentCollectedByStaffId;
  String? _paymentStaffName = "Select Staff";
  ReturnDetailsData? _details;
  List<String> _paymentStatuses = ['Unpaid', 'Paid', 'Partial'];
  final List<String> _paymentMethods = ['Cash', 'Bank'];
  List<dynamic> _generalStaff = []; // To store staff list from getStaffs()

  double _grandTotal = 0.0;
  double _invoiceAmount = 0.0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  final TextEditingController _totalPaidAmountController =
      TextEditingController(text: "0.00");
  final TextEditingController _remarksController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.customerId != null) {
      _selectedCustomerId = widget.customerId;
      _selectedCustomerName = widget.customerName ?? "Select Customer";
    }
    if (widget.locationId != null) {
      _selectedLocationId = widget.locationId;
    }
    if (widget.rentId != null) {
      _selectedRentId = widget.rentId;
    }

    _returnDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
    _invoiceDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCustomers(),
        _loadGeneralStaff(),
      ]);

      if (_selectedCustomerId != null) {
        await _loadLocations();
        await _loadCustomerStaff();
        if (_selectedLocationId != null) {
          await _loadRentIds();
          if (_selectedRentId != null) {
            await _fetchReturnDetails();
          }
        }
      }
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

  Future<void> _loadLocations() async {
    if (_selectedCustomerId == null) return;
    final data =
        await HttpService.getRentalCustomerLocations(_selectedCustomerId!);
    if (data != null && data.status) {
      setState(() => _locations = data.data);
    }
  }

  Future<void> _loadRentIds() async {
    if (_selectedCustomerId == null || _selectedLocationId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await HttpService.getRentIdsByCustomer(
          _selectedCustomerId!, _selectedLocationId!);
      if (data != null && data.status) {
        setState(() {
          _rentalIssues = data.data;
          // Preserve selection if it exists in the new list
          if (_selectedRentId != null &&
              !_rentalIssues.any((issue) => issue.id == _selectedRentId)) {
            _selectedRentId = null;
            _productRows = [RentalReturnRow()];
            _details = null;
          }
        });
      }
    } catch (e) {
      log('Error loading rent IDs: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadCustomerStaff() async {
    if (_selectedCustomerId == null) return;

    try {
      final data =
          await HttpService.getCollectedStaffRentalList(_selectedCustomerId!);
      if (data != null && data.status) {
        setState(() {
          _customerStaff = data.data;
        });
      }
    } catch (e) {
      log('Error loading customer staff: $e');
    }
  }

  Future<void> _loadGeneralStaff() async {
    try {
      final data = await HttpService.getStaffs();
      if (data != null && data.status) {
        setState(() {
          _generalStaff = data.data;
        });
      }
    } catch (e) {
      log('Error loading general staff: $e');
    }
  }

  Future<void> _fetchReturnDetails() async {
    if (_selectedCustomerId == null ||
        _selectedLocationId == null ||
        _selectedRentId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await HttpService.getReturnDetails(
        _selectedCustomerId!,
        _selectedLocationId!,
        _selectedRentId!,
      );

      if (data != null && data.status) {
        setState(() {
          _details = data.data;
          // Populate product rows from return details
          final String issuedDateStr = data.data.issuedDate;
          _productRows = data.data.items.map((item) {
            final row = RentalReturnRow()
              ..selectedProductId = item.id
              ..productName = item.productName
              ..unitPrice = double.tryParse(item.unitPrice) ?? 0.0
              ..maxQty = item.qtyRemaining
              ..returningQty = 0
              ..damagedQty = 0
              ..isReturning = false
              ..isDamaged = false
              ..noOfDaysController.text = _calculateDuration(issuedDateStr);

            row.ratePerDayController.text = row.unitPrice.toStringAsFixed(2);
            _recalculateRowInternal(row);
            return row;
          }).toList();

          if (_productRows.isEmpty) {
            _productRows = [RentalReturnRow()];
          }
          _calculateSummary();
        });
      }
    } catch (e) {
      log('Error fetching return details: $e');
    }
    setState(() => _isLoading = false);
  }

  String _calculateDuration(String? issuedDateStr) {
    if (issuedDateStr == null || issuedDateStr.isEmpty) return "1";
    try {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final DateTime issuedDate = formatter.parse(issuedDateStr);
      final DateTime returnDate = formatter.parse(_returnDateController.text);
      final int days = returnDate.difference(issuedDate).inDays;
      return (days < 1 ? 1 : days).toString();
    } catch (e) {
      return "1";
    }
  }

  void _recalculateRowInternal(RentalReturnRow row) {
    final quantity = (row.returningQty + row.damagedQty).toDouble();
    final ratePerDay = double.tryParse(row.ratePerDayController.text) ?? 0;
    final noOfDays = double.tryParse(row.noOfDaysController.text) ?? 0;
    final grossAmount = quantity * ratePerDay * noOfDays;
    row.grossAmountController.text = grossAmount.toStringAsFixed(2);

    final gstPercent = double.tryParse(row.gstPercentController.text) ?? 18.0;
    final gstAmount = grossAmount * (gstPercent / 100);
    row.gstAmountController.text = gstAmount.toStringAsFixed(2);

    final total = grossAmount + gstAmount;
    row.totalController.text = grossAmount.toStringAsFixed(2);
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
    _recalculateRowInternal(_productRows[index]);
    _calculateSummary();
  }

  void _calculateSummary() {
    double totalAmount = 0;
    for (final row in _productRows) {
      totalAmount += double.tryParse(row.totalController.text) ?? 0;
    }
    final otherExpenses = double.tryParse(_otherExpensesController.text) ?? 0;
    setState(() {
      _invoiceAmount = totalAmount + otherExpenses;
      // _grandTotal = (_details?.previousGrandTotal ?? 0) + _invoiceAmount;
      _grandTotal = totalAmount;
      if (_selectedPaymentStatus == 'Paid') {
        _totalPaidAmountController.text =
            (_grandTotal - (_details?.previousAmountPaid ?? 0))
                .toStringAsFixed(2);
      }
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
        if (controller == _returnDateController) {
          _updateAllDurations();
        }
      });
    }
  }

  void _updateAllDurations() {
    if (_details == null) return;
    final String issuedDateStr = _details!.issuedDate;
    for (var row in _productRows) {
      row.noOfDaysController.text = _calculateDuration(issuedDateStr);
      _recalculateRowInternal(row);
    }
    _calculateSummary();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Verify at least one item has a returning quality > 0
    bool hasReturning = _productRows.any((row) => row.returningQty > 0);
    if (!hasReturning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('At least one "Returning" quantity is required.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      Map<String, dynamic> formData = {
        'token': await Common.getSharedPref('token'),
        'customer_id': _selectedCustomerId,
        'rent_id': _selectedRentId, // Added rent_id
        'staff_id': _selectedStaffId, // Added staff_id
        'return_date': _returnDateController.text,
        'invoice_date': _returnDateController
            .text, // Use return date for invoice date if needed
        'location': _selectedLocationId,
        'other_expenses': _otherExpensesController.text,
        'grand_total': _grandTotal.toStringAsFixed(2),
        'invoice_amount': _invoiceAmount.toStringAsFixed(2),
        'payment_status': _selectedPaymentStatus,
        'total_paid_amount': _totalPaidAmountController.text,
        'payment_method': _selectedPaymentMethod,
        'payment_collected_by': _paymentCollectedByStaffId,
        'remarks': _remarksController.text,
        'products': _productRows
            .where((row) => row.selectedProductId != null)
            .map((row) => {
                  'material_id': row.selectedProductId,
                  'quantity': row.returningQty.toString(),
                  'damaged_quantity': row.damagedQty.toString(),
                  'rate_per_day': row.ratePerDayController.text,
                  'no_of_days': row.noOfDaysController.text,
                  'gross_amount': row.grossAmountController.text,
                  'gst_percent': row.gstPercentController.text,
                  'gst_amount': row.gstAmountController.text,
                  'total': row.totalController.text,
                  'returning': row.isReturning ? '1' : '0',
                  'damaged': row.isDamaged ? '1' : '0',
                })
            .toList(),
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
            content:
                Text(response?['message'] ?? 'Failed to create rental return'),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                  const Icon(Icons.inventory, color: Colors.blue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    row.productName ?? 'Product ${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_productRows.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 14),
                  onPressed: () => _removeProductRow(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          // Selection for Returning and Damaged
          Row(
            children: [
              _buildCompactCheckbox(
                label: 'Returning',
                value: row.isReturning,
                onChanged: (val) {
                  setState(() {
                    row.isReturning = val ?? false;
                    if (!row.isReturning) {
                      row.returningQty = 0;
                      _recalculateRowInternal(row);
                      _calculateSummary();
                    }
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildCompactCheckbox(
                label: 'Damaged',
                value: row.isDamaged,
                onChanged: (val) {
                  setState(() {
                    row.isDamaged = val ?? false;
                    if (!row.isDamaged) {
                      row.damagedQty = 0;
                    }
                  });
                },
              ),
            ],
          ),
          if (row.isReturning || row.isDamaged) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (row.isReturning)
                  _buildQuantitySelector(
                    'Returning Qty *',
                    row.returningQty,
                    row.maxQty - row.damagedQty,
                    (val) => setState(() {
                      row.returningQty = val;
                      _recalculateRowInternal(row);
                      _calculateSummary();
                    }),
                  ),
                if (row.isReturning && row.isDamaged) const SizedBox(width: 8),
                if (row.isDamaged)
                  _buildQuantitySelector(
                    'Damaged Qty',
                    row.damagedQty,
                    row.maxQty - row.returningQty,
                    (val) => setState(() {
                      row.damagedQty = val;
                      _recalculateRowInternal(row);
                      _calculateSummary();
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),

          // Rate, Days, Total
          Row(
            children: [
              _buildCompactField('Rent Price', row.ratePerDayController, index,
                  readOnly: true),
              const SizedBox(width: 6),
              _buildCompactField('Days', row.noOfDaysController, index,
                  readOnly: true),
              const SizedBox(width: 6),
              _buildCompactField('Total', row.totalController, index,
                  readOnly: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(
      String label, int value, int max, Function(int) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              Text('/ $max',
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline,
                      size: 20, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text('$value',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () {
                    if (value < max) {
                      onChanged(value + 1);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot exceed available quantity'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline,
                      size: 20, color: Colors.green),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCheckbox(
      {required String label,
      required bool value,
      required ValueChanged<bool?> onChanged}) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCompactField(
      String label, TextEditingController controller, int index,
      {bool readOnly = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onChanged: readOnly ? null : (_) => _recalculateRow(index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Rental Return',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
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
                      title: 'Customer & Site*',
                      icon: Icons.person,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showCustomerDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedCustomerName ??
                                              "Select Customer",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _selectedCustomerId != null
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 20, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedLocationId,
                                    isExpanded: true,
                                    hint: const Text('Site',
                                        style: TextStyle(fontSize: 12)),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        size: 20),
                                    items: _locations.map((location) {
                                      return DropdownMenuItem<String>(
                                        value: location.id,
                                        child: Text(location.locationName,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedLocationId = value;
                                        _selectedRentId = null;
                                        _rentalIssues = [];
                                      });
                                      if (value != null) {
                                        _loadRentIds();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedRentId,
                                    isExpanded: true,
                                    hint: const Text('Rent ID',
                                        style: TextStyle(fontSize: 12)),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        size: 20),
                                    items: _rentalIssues.map((issue) {
                                      return DropdownMenuItem<String>(
                                        value: issue.id,
                                        child: Text(issue.rentNo,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedRentId = value);
                                      if (value != null) {
                                        _fetchReturnDetails();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStaffId,
                                    isExpanded: true,
                                    hint: const Text('Staff',
                                        style: TextStyle(fontSize: 12)),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        size: 20),
                                    items: _customerStaff.map((staff) {
                                      return DropdownMenuItem<String>(
                                        value: staff.id,
                                        child: Text(staff.customerStaff,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedStaffId = value);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Dates',
                      icon: Icons.calendar_month,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: TextEditingController(
                                    text: _details?.issuedDate ?? ""),
                                readOnly: true,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Issue Date',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today,
                                      size: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDateField(
                                  'Return Date*', _returnDateController, true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildSectionCard(
                      title: 'Products',
                      icon: Icons.shopping_cart,
                      children: [
                        const SizedBox(height: 8),
                        ...List.generate(_productRows.length, (index) {
                          return _buildProductRow(index);
                        }),
                        // const SizedBox(height: 12),
                        // Center(
                        //   child: ElevatedButton.icon(
                        //     onPressed: _addProductRow,
                        //     icon: const Icon(Icons.add, size: 16),
                        //     label: const Text('Add Product'),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: const Color(0xFF2a86c9),
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.symmetric(
                        //           horizontal: 16, vertical: 10),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Previous Details',
                      icon: Icons.history,
                      children: [
                        const SizedBox(height: 8),
                        _buildSummaryRow('Previous Total',
                            '₹${(_details?.previousGrandTotal ?? 0).toStringAsFixed(2)}'),
                        _buildSummaryRow('Previously Paid',
                            '₹${(_details?.previousAmountPaid ?? 0).toStringAsFixed(2)}'),
                        _buildSummaryRow('Prev. Balance',
                            '₹${(_details?.previousBalance ?? 0).toStringAsFixed(2)}',
                            isBold: true),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildSectionCard(
                      title: 'Summary',
                      icon: Icons.summarize,
                      children: [
                        const SizedBox(height: 8),
                        _buildSummaryRow('Grand Total',
                            '₹${_grandTotal.toStringAsFixed(2)}'),
                        // _buildSummaryRow('Total Balance',
                        //     '₹${((_details?.previousBalance ?? 0) + _grandTotal).toStringAsFixed(2)}',
                        //     isBold: true),
                        const SizedBox(height: 8),

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
                            prefixIcon:
                                const Icon(Icons.monetization_on, size: 20),
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

                    const SizedBox(height: 12),
                    _buildPaymentSection(),
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2a86c9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildSectionCard(
      title: "Payment Details",
      icon: Icons.payment,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFormRow(
                "Pay Status * :",
                _dropdown(
                    _paymentStatuses, _selectedPaymentStatus, "Select Status",
                    (newVal) {
                  setState(() {
                    _selectedPaymentStatus = newVal;
                    if (_selectedPaymentStatus == 'Unpaid') {
                      _totalPaidAmountController.text = "0.00";
                    } else if (_selectedPaymentStatus == 'Paid') {
                      _totalPaidAmountController.text =
                          (_grandTotal - (_details?.previousAmountPaid ?? 0))
                              .toStringAsFixed(2);
                    } else if (_selectedPaymentStatus == 'Partial') {
                      _totalPaidAmountController.text = "";
                    }
                  });
                }),
              ),
            ),
            const SizedBox(width: 12),
            if (_selectedPaymentStatus != "Unpaid")
              Expanded(
                child: _buildFormRow(
                  "Paid Amount * :",
                  TextFormField(
                    controller: _totalPaidAmountController,
                    keyboardType: TextInputType.number,
                    readOnly: _selectedPaymentStatus == 'Paid',
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDecoration().copyWith(
                        fillColor: _selectedPaymentStatus == 'Paid'
                            ? Colors.grey.shade100
                            : Colors.grey.shade50),
                    onChanged: (val) {
                      _calculateSummary();
                    },
                  ),
                ),
              ),
          ],
        ),
        if (_selectedPaymentStatus == 'Paid' ||
            _selectedPaymentStatus == 'Partial') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormRow(
                  "Pay Method * :",
                  _dropdown(
                      _paymentMethods, _selectedPaymentMethod, "Select Method",
                      (val) {
                    setState(() => _selectedPaymentMethod = val);
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormRow(
                  "Collected By * :",
                  GestureDetector(
                    onTap: () => _showPaymentStaffDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _paymentStaffName ?? "Select",
                              style: TextStyle(
                                fontSize: 13,
                                color: _paymentCollectedByStaffId != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildFormRow(
          "Remarks",
          TextFormField(
            controller: _remarksController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration:
                _inputDecoration().copyWith(hintText: "Enter remarks here..."),
          ),
        ),
      ],
    );
  }

  void _showCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final List<CustomerExp> filtered = _customers
                .where((c) =>
                    c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: const Text("Select Customer"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: "Search Customer",
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filtered[index].name,
                                style: const TextStyle(fontSize: 14)),
                            onTap: () {
                              setState(() {
                                _selectedCustomerId = filtered[index].id;
                                _selectedCustomerName = filtered[index].name;
                                _selectedLocationId = null;
                                _selectedRentId = null;
                                _locations = [];
                                _rentalIssues = [];
                                _customerStaff = [];
                              });
                              _loadLocations();
                              _loadCustomerStaff();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final List<dynamic> sourceList = _generalStaff;

            final List<Map<String, String>> filtered = sourceList
                .where((s) {
                  final name = s.name.toString().toLowerCase();
                  return name.contains(searchQuery.toLowerCase());
                })
                .map((s) => {"id": s.id.toString(), "name": s.name.toString()})
                .toList();

            return AlertDialog(
              title: const Text("Select Staff"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                      decoration: const InputDecoration(
                          hintText: "Search Staff",
                          prefixIcon: Icon(Icons.search)),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filtered[index]["name"]!),
                            onTap: () {
                              setState(() {
                                _paymentCollectedByStaffId =
                                    filtered[index]["id"];
                                _paymentStaffName = filtered[index]["name"];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdown(List<String> items, String? value, String hint,
      Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(hint, style: const TextStyle(fontSize: 13)),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(e, style: const TextStyle(fontSize: 13))),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFormRow(String title, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 12)),
          const SizedBox(height: 6),
          child,
        ],
      );

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2a86c9), width: 1),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2a86c9), size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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

  Widget _buildDateField(
      String label, TextEditingController controller, bool isRequired) {
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
  final TextEditingController ratePerDayController = TextEditingController();
  final TextEditingController noOfDaysController = TextEditingController();
  final TextEditingController grossAmountController = TextEditingController();
  final TextEditingController gstPercentController =
      TextEditingController(text: "18");
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  String? selectedProductId;
  String? productName;
  double unitPrice = 0.0;
  int returningQty = 0;
  int damagedQty = 0;
  int maxQty = 0;
  bool isReturning = false;
  bool isDamaged = false;

  RentalReturnRow();
}
