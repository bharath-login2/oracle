import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/rental/rentalCustomerLocations.dart';
import 'package:login2/models/rental/rentalCollectedByStaffList.dart' as rcs;
import 'package:login2/screens/accounts/clients/addClients.dart';
import 'package:login2/service/service.dart';

class AddRentalIssuePage extends StatefulWidget {
  final String? rentId;
  const AddRentalIssuePage({super.key, this.rentId});

  @override
  State<AddRentalIssuePage> createState() => _AddRentalIssuePageState();
}

class _AddRentalIssuePageState extends State<AddRentalIssuePage> {
  final HttpService _httpService = HttpService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();
  final TextEditingController _advanceAmountController =
      TextEditingController();
  final TextEditingController _totalPaidAmountController =
      TextEditingController(text: "0.00");
  final TextEditingController _discountController =
      TextEditingController(text: "0");
  final TextEditingController _otherExpensesController =
      TextEditingController(text: "0");
  final TextEditingController _rentIssueIdController =
      TextEditingController(text: "#RIN");
  final TextEditingController _invoiceNoController =
      TextEditingController(text: "#");
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();

  String? _selectedCustomerId;
  String? _selectedLocationId;
  String? _selectedPaymentStatus = 'Unpaid';
  String? _selectedCollectedByStaffId;
  String? _selectedStaffName = "Select Staff";
  String? _paymentCollectedByStaffId;
  String? _paymentStaffName = "Select Staff";
  List<CustomerExp> _customers = [];
  List<MaterialData> _materials = [];
  List<MaterialData> _searchResults = [];
  List<LocationData> _customerLocations = [];
  List<Staff> _staffs = [];
  List<rcs.Staff> _collectedStaffs = [];
  List<String> _paymentStatuses = ['Unpaid', 'Paid', 'Partial'];
  final List<String> _paymentMethods = ['Cash', 'Bank'];
  String? _selectedPaymentMethod = 'Cash';
  List<ProductRow> _productRows = [ProductRow()];
  double _totalGrossAmount = 0.0;
  double _gstAmount = 0.0;
  double _grandTotal = 0.0;
  int _totalDays = 1;
  bool _isLoading = false;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _loadData();
    _invoiceDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
    _fromDateController.text =
        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    _toDateController.text =
        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    if (widget.rentId != null) {
      _loadEditData();
    } else {
      _loadData();
    }
    _updateTotalDays();
  }

  Future<void> _loadEditData() async {
    setState(() => _isLoading = true);
    try {
      await _loadData(); // Base data like customers, staff, materials
      final response = await HttpService.rentIssueDetails(widget.rentId!);
      if (response != null && response.status) {
        final issue = response.data.rentIssue;
        _selectedCustomerId = issue.customerId;
        await _loadCustomerLocations(_selectedCustomerId!);
        await _loadCollectedStaffs(_selectedCustomerId!);

        _selectedLocationId = issue.locationId;
        _selectedCollectedByStaffId = issue.collectedRent;
        _selectedStaffName = issue.collectedStaffName;

        _invoiceDateController.text = issue.invoiceDate;
        _fromDateController.text = issue.fromDate.split(' ')[0];
        _toDateController.text = issue.toDate.split(' ')[0];
        _totalDaysController.text = issue.totalDays;
        _advanceAmountController.text = issue.advanceAmount;
        _discountController.text = issue.discount;
        _otherExpensesController.text = issue.otherExpenses;
        _rentIssueIdController.text = issue.rentNo;
        _invoiceNoController.text = issue.invoiceNo;
        _totalPaidAmountController.text = issue.amountPaid;

        // Load products
        _productRows.clear();
        for (var item in response.data.rentItems) {
          final row = ProductRow();
          row.selectedProductId = item.productId;
          row.quantityController.text = item.qty;
          row.unitPriceController.text = item.unitPrice;
          row.ratePerDayController.text = item.ratePerDay;
          row.noOfDaysController.text = item.days;
          row.fromDateController.text = issue.fromDate.split(' ')[0];
          row.toDateController.text = issue.toDate.split(' ')[0];
          row.grossAmountController.text = item.gross;
          row.gstPercentController.text = item.gstPercent;
          row.gstAmountController.text = item.gstAmount;
          row.totalController.text = item.total;
          row.hasGst = double.tryParse(item.gstPercent) != null &&
              double.parse(item.gstPercent) > 0;
          _productRows.add(row);
        }
        if (_productRows.isEmpty) _productRows.add(ProductRow());
        _recalculateAllRows();
      }
    } catch (e) {
      log('Error loading edit data: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadCustomers(),
        _loadMaterials(),
        _loadStaffs(),
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

  Future<void> _loadStaffs() async {
    final data = await HttpService.getStaffs();
    if (data != null && data.status) {
      setState(() => _staffs = data.data);
    }
  }

  void _onProductSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = _materials
            .where((m) => (m.materialName ?? "")
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addProductFromSearch(MaterialData mat) {
    double stock = double.tryParse(mat.currentStock ?? "0") ?? 0;
    if (stock <= 0) {
      Common.toastMessaage('Product is out of stock', Colors.red);
      return;
    }

    setState(() {
      // Check if already added
      bool exists =
          _productRows.any((row) => row.selectedProductId == mat.materialId);
      if (!exists) {
        final newRow = ProductRow();
        newRow.selectedProductId = mat.materialId;
        newRow.unitPriceController.text = mat.unitPrice ?? "0";
        newRow.ratePerDayController.text = mat.unitPrice ?? "0";
        newRow.currentStock = mat.currentStock;
        newRow.gstPercentController.text = mat.gstPercentage ?? "0";
        newRow.hasGst =
            mat.gstPercentage != null && mat.gstPercentage!.isNotEmpty;
        newRow.noOfDaysController.text = _totalDays.toString();
        newRow.fromDateController.text = _fromDateController.text;
        newRow.toDateController.text = _toDateController.text;
        newRow.quantityController.text = "1";
        // If the first row is empty, replace it, otherwise add new
        if (_productRows.length == 1 &&
            _productRows[0].selectedProductId == null) {
          _productRows[0] = newRow;
        } else {
          _productRows.add(newRow);
        }
        _recalculateAllRows();
      }
      _productSearchController.clear();
      _searchResults.clear();
    });
  }

  Future<void> _loadCustomerLocations(String customerId) async {
    final data = await HttpService.getRentalCustomerLocations(customerId);
    if (data != null && data.status) {
      setState(() {
        _customerLocations = data.data;
        _selectedLocationId = null;
      });
    }
  }

  Future<void> _loadCollectedStaffs(String customerId) async {
    final data = await HttpService.getCollectedStaffRentalList(customerId);
    if (data != null && data.status) {
      setState(() {
        _collectedStaffs = data.data;
      });
    } else {
      setState(() {
        _collectedStaffs = [];
      });
    }
  }

  void _updateTotalDays() {
    if (_fromDateController.text.isNotEmpty &&
        _toDateController.text.isNotEmpty) {
      try {
        final fromDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(_fromDateController.text);
        final toDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(_toDateController.text);
        final difference = toDate.difference(fromDate).inDays;
        _totalDays = difference >= 0 ? difference + 1 : 1;
        _totalDaysController.text = _totalDays.toString();
        // Update No of Days and Dates for all product rows to match the new duration
        for (final row in _productRows) {
          row.noOfDaysController.text = _totalDays.toString();
          row.fromDateController.text = _fromDateController.text;
          row.toDateController.text = _toDateController.text;
        }
        _recalculateAllRows();
      } catch (e) {
        log("Error updating total days: $e");
        _totalDaysController.text = "0";
      }
    }
  }

  void _removeProductRow(int index) {
    setState(() {
      _productRows.removeAt(index);
      _recalculateAllRows();
    });
  }

  void _recalculateRow(int index) {
    final row = _productRows[index];
    final quantity = double.tryParse(row.quantityController.text) ?? 0;
    final ratePerDay = double.tryParse(row.ratePerDayController.text) ?? 0;
    final noOfDays =
        double.tryParse(row.noOfDaysController.text) ?? _totalDays.toDouble();
    final grossAmount = quantity * ratePerDay * noOfDays;
    row.grossAmountController.text = grossAmount.toStringAsFixed(2);
    double gstAmount = 0;
    if (row.hasGst && row.gstPercentController.text.isNotEmpty) {
      final gstPercent = double.tryParse(row.gstPercentController.text) ?? 0;
      gstAmount = grossAmount * (gstPercent / 100);
    }
    row.gstAmountController.text = gstAmount.toStringAsFixed(2);
    final total = grossAmount + gstAmount;
    row.totalController.text = total.toStringAsFixed(2);
    _calculateSummary();
  }

  void _updateRowDaysFromDates(int index) {
    final row = _productRows[index];
    if (row.fromDateController.text.isNotEmpty &&
        row.toDateController.text.isNotEmpty) {
      try {
        final fromDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(row.fromDateController.text);
        final toDate =
            DateFormat('dd-MM-yyyy HH:mm').parse(row.toDateController.text);
        final difference = toDate.difference(fromDate).inDays;
        row.noOfDaysController.text =
            (difference >= 0 ? difference + 1 : 1).toString();
        _recalculateRow(index);
      } catch (e) {
        log("Error updating row days: $e");
      }
    }
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
      _totalPaidAmountController.text =
          (advance + totalPaid).toStringAsFixed(2);
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller == _fromDateController
          ? DateTime.now()
          : (DateFormat('dd-MM-yyyy HH:mm')
                      .parse(_fromDateController.text)
                      .isAfter(DateTime.now())
                  ? DateFormat('dd-MM-yyyy HH:mm')
                      .parse(_fromDateController.text)
                  : DateTime.now()),
      firstDate: controller == _fromDateController
          ? DateTime.now()
          : DateFormat('dd-MM-yyyy HH:mm').parse(_fromDateController.text),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          controller.text = DateFormat('dd-MM-yyyy HH:mm').format(fullDateTime);
          if (controller == _fromDateController ||
              controller == _toDateController) {
            _updateTotalDays();
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_selectedCustomerId == null) {
      Common.toastMessaage('Please select a customer', Colors.red);
      return;
    }
    if (_productRows.isEmpty ||
        _productRows.every((row) => row.selectedProductId == null)) {
      Common.toastMessaage('Please add at least one product', Colors.red);
      return;
    }
    if (_selectedLocationId == null) {
      Common.toastMessaage('Please select a work site', Colors.red);
      return;
    }
    // if (_selectedCollectedByStaffId == null) {
    //   Common.toastMessaage('Please select a collected staff', Colors.red);
    //   return;
    // }

    // Payment validation
    if (_selectedPaymentStatus == 'Paid' ||
        _selectedPaymentStatus == 'Partial') {
      if (_selectedPaymentMethod == null) {
        Common.toastMessaage('Please select a payment method', Colors.red);
        return;
      }
      if (_paymentCollectedByStaffId == null) {
        Common.toastMessaage('Please select a payment collector', Colors.red);
        return;
      }
    }

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
        if (widget.rentId != null) 'id': widget.rentId,
        'customer_id': _selectedCustomerId,
        'from_date': "${_fromDateController.text}:00",
        'to_date': "${_toDateController.text}:00",
        'invoice_date': _invoiceDateController.text,
        'location': _selectedLocationId,
        'total_days': _totalDays.toString(),
        'advance_amount': _advanceAmountController.text,
        'payment_status': _selectedPaymentStatus,
        'total_paid_amount': _totalPaidAmountController.text,
        'discount': _discountController.text,
        'other_expenses': _otherExpensesController.text,
        'grand_total': _grandTotal.toStringAsFixed(2),
        'collected_by': _selectedCollectedByStaffId,
        'payment_collected_by': _paymentCollectedByStaffId,
        'invoice_no': _invoiceNoController.text,
        'rental_issue_id': _rentIssueIdController.text,
        'products': _productRows
            .where((row) => row.selectedProductId != null)
            .map((row) => {
                  'material_id': row.selectedProductId,
                  'quantity': row.quantityController.text,
                  'rate_per_day': row.ratePerDayController.text,
                  'no_of_days': row.noOfDaysController.text,
                  'from_date': row.fromDateController.text,
                  'to_date': row.toDateController.text,
                  'gross_amount': row.grossAmountController.text,
                  'gst_percent': row.gstPercentController.text.isNotEmpty
                      ? row.gstPercentController.text
                      : "0",
                  'gst_amount': row.gstAmountController.text,
                  'total': row.totalController.text,
                })
            .toList(),
      };

      final response = widget.rentId != null
          ? await HttpService.editRentalIssue(formData)
          : await HttpService.createRentalIssue(formData);

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.rentId != null
                ? 'Rental Issue updated successfully'
                : 'Rental Issue created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ??
                (widget.rentId != null
                    ? 'Failed to update rental issue'
                    : 'Failed to create rental issue')),
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

  Widget _buildMinimalProductRow(int index) {
    final row = _productRows[index];
    final mat = _materials.firstWhere(
        (m) => m.materialId == row.selectedProductId,
        orElse: () => MaterialData());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Colors.blue, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mat.materialName ?? "Unknown Product",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Builder(builder: (context) {
                      final stockValue =
                          double.tryParse(mat.currentStock ?? '0') ?? 0;
                      final isAvailable = stockValue > 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          isAvailable
                              ? "Stock: ${mat.currentStock ?? '0'}"
                              : "No stock available",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  row.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.blue,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    row.isExpanded = !row.isExpanded;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade300, size: 20),
                onPressed: () => _removeProductRow(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 0.5),
          ),
          if (!row.isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Qty: ${row.quantityController.text} | Price: ₹ ${row.ratePerDayController.text} | Days: ${row.noOfDaysController.text}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (row.isExpanded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFormRow(
                    "Quantity",
                    _counterField(
                        row.quantityController, () => _recalculateRow(index)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormRow(
                    "Rental Price",
                    TextFormField(
                      controller: row.ratePerDayController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: _inputDecoration(isDense: true),
                      onChanged: (_) => _recalculateRow(index),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildFormRow(
            //         "From Date",
            //         GestureDetector(
            //           onTap: () async {
            //             await _selectDate(context, row.fromDateController);
            //             _updateRowDaysFromDates(index);
            //           },
            //           child: Container(
            //             padding: const EdgeInsets.all(12),
            //             decoration: _boxDecoration(),
            //             child: Row(
            //               children: [
            //                 Expanded(
            //                   child: Text(
            //                     row.fromDateController.text,
            //                     style: const TextStyle(fontSize: 12),
            //                   ),
            //                 ),
            //                 const Icon(Icons.calendar_today, size: 16),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: _buildFormRow(
            //         "To Date",
            //         GestureDetector(
            //           onTap: () async {
            //             await _selectDate(context, row.toDateController);
            //             _updateRowDaysFromDates(index);
            //           },
            //           child: Container(
            //             padding: const EdgeInsets.all(12),
            //             decoration: _boxDecoration(),
            //             child: Row(
            //               children: [
            //                 Expanded(
            //                   child: Text(
            //                     row.toDateController.text,
            //                     style: const TextStyle(fontSize: 12),
            //                   ),
            //                 ),
            //                 const Icon(Icons.calendar_today, size: 16),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildFormRow(
                    "No of Days",
                    _counterField(
                        row.noOfDaysController, () => _recalculateRow(index)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormRow(
                    "Total",
                    TextFormField(
                      controller: row.totalController,
                      readOnly: true,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                      decoration: _inputDecoration(isDense: true)
                          .copyWith(fillColor: Colors.blue.shade50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.rentId != null ? 'Edit Rental Issue' : 'Add Rental Issue',
          style: const TextStyle(color: Colors.white, fontSize: 18),
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Client & Staff Info',
                      icon: Icons.info_outline,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                "Customer *:",
                                GestureDetector(
                                  onTap: () => _showCustomerDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: _boxDecoration(),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedCustomerId != null
                                                ? _customers
                                                    .firstWhere((c) =>
                                                        c.id ==
                                                        _selectedCustomerId)
                                                    .name
                                                : "Select",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _selectedCustomerId != null
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormRow(
                                "Site * :",
                                _dropdown(
                                  _customerLocations
                                      .map((l) => l.locationName)
                                      .toList(),
                                  _selectedLocationId != null &&
                                          _customerLocations.any((l) =>
                                              l.id == _selectedLocationId)
                                      ? _customerLocations
                                          .firstWhere((l) =>
                                              l.id == _selectedLocationId)
                                          .locationName
                                      : null,
                                  "Select Location",
                                  (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedLocationId = _customerLocations
                                            .firstWhere(
                                                (l) => l.locationName == val)
                                            .id;
                                      });
                                    }
                                  },
                                  suffixAction: IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _addWorkSiteDialog(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                "Customer Staff :",
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: _boxDecoration(),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _showStaffDialog(context,
                                              isPayment: false),
                                          child: Text(
                                            _selectedStaffName ?? "Select",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  _selectedCollectedByStaffId !=
                                                          null
                                                      ? Colors.black
                                                      : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _showStaffDialog(context,
                                            isPayment: false),
                                        child: const Icon(Icons.arrow_drop_down,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _addCollectedStaffDialog(context),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormRow(
                                "Invoice Date :",
                                GestureDetector(
                                  onTap: () => _selectDate(
                                      context, _invoiceDateController),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: _boxDecoration(),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _invoiceDateController.text
                                                .split(' ')[0],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today,
                                            size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 12),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: _buildFormRow(
                        //         "Invoice Number :",
                        //         TextFormField(
                        //           controller: _invoiceNoController,
                        //           readOnly: true,
                        //           style: const TextStyle(
                        //               fontSize: 13,
                        //               fontWeight: FontWeight.bold,
                        //               color: Colors.blue),
                        //           decoration: _inputDecoration(isDense: true)
                        //               .copyWith(fillColor: Colors.blue.shade50),
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 12),
                        //     Expanded(
                        //       child: _buildFormRow(
                        //         "Rent Issue ID :",
                        //         TextFormField(
                        //           controller: _rentIssueIdController,
                        //           readOnly: true,
                        //           style: const TextStyle(
                        //               fontSize: 13,
                        //               fontWeight: FontWeight.bold,
                        //               color: Colors.blue),
                        //           decoration: _inputDecoration(isDense: true)
                        //               .copyWith(fillColor: Colors.blue.shade50),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _minimalDateItem("Issue Date", _fromDateController),
                          _minimalDateItem("Due Date", _toDateController),
                          _minimalDaysItemDays(
                              "No of Days", _totalDaysController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionCard(
                      title: 'Items & Summary',
                      icon: Icons.inventory_2,
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: _productSearchController,
                          onChanged: _onProductSearch,
                          decoration: _inputDecoration().copyWith(
                            hintText: 'Search Product...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _productSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _productSearchController.clear();
                                        _searchResults.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                        if (_searchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border.all(color: Colors.blue.shade50),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _searchResults.length,
                              separatorBuilder: (context, index) => Divider(
                                  height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, idx) {
                                final mat = _searchResults[idx];
                                final stock =
                                    double.tryParse(mat.currentStock ?? "0") ??
                                        0;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  title: Text(mat.materialName ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  subtitle: Row(
                                    children: [
                                      Text("Price: ₹${mat.unitPrice}",
                                          style: const TextStyle(fontSize: 11)),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: stock > 0
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "Stock: $stock",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: stock > 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.add_circle_outline,
                                      color: Colors.blue, size: 20),
                                  onTap: () => _addProductFromSearch(mat),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        ...List.generate(_productRows.length, (index) {
                          if (_productRows[index].selectedProductId == null) {
                            return const SizedBox();
                          }
                          return _buildMinimalProductRow(index);
                        }),
                        const Divider(height: 32),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildMinimalSummaryRow("Total Gross Amount",
                                  "₹${_totalGrossAmount.toStringAsFixed(2)}"),
                              _buildMinimalSummaryRow("GST Amount",
                                  "₹${_gstAmount.toStringAsFixed(2)}"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormRow(
                                      "Discount",
                                      TextFormField(
                                        controller: _discountController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration().copyWith(
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (_) => _calculateSummary(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFormRow(
                                      "Other Expense",
                                      TextFormField(
                                        controller: _otherExpensesController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration().copyWith(
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (_) => _calculateSummary(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Grand Total",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text("₹${_grandTotal.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    _buildPaymentSection(),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Save Rental Issue',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
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
                "Payment Status * :",
                _dropdown(
                    _paymentStatuses, _selectedPaymentStatus, "Select Status",
                    (newVal) {
                  setState(() {
                    _selectedPaymentStatus = newVal;
                    if (_selectedPaymentStatus == 'Unpaid') {
                      _totalPaidAmountController.text = "0.00";
                    } else if (_selectedPaymentStatus == 'Paid') {
                      _totalPaidAmountController.text =
                          _grandTotal.toStringAsFixed(2);
                    }
                  });
                }),
              ),
            ),
            const SizedBox(width: 12),
            if (_selectedPaymentStatus != "Unpaid")
              Expanded(
                child: _buildFormRow(
                  "Total Paid Amount * :",
                  TextFormField(
                    controller: _totalPaidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(),
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
                  "Payment Detail * :",
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
                    onTap: () => _showStaffDialog(context, isPayment: true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _boxDecoration(),
                      child: Text(
                        _paymentStaffName ?? "Select",
                        style: TextStyle(
                          color: _paymentCollectedByStaffId != null
                              ? Colors.black
                              : Colors.grey,
                        ),
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
            decoration:
                _inputDecoration().copyWith(hintText: "Enter remarks here..."),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(List<String> items, String? value, String hint,
      Function(String?) onChanged,
      {Widget? suffixAction}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: items.contains(value) ? value : null,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(hint, style: const TextStyle(fontSize: 14)),
                ),
                items: items
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(e,
                                  style: const TextStyle(fontSize: 14))),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (suffixAction != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: suffixAction,
            ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String title, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 13),
              children: _parseTitle(title),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      );

  List<TextSpan> _parseTitle(String title) {
    List<TextSpan> spans = [];
    List<String> parts = title.split('*');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(const TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
      }
    }
    return spans;
  }

  InputDecoration _inputDecoration({bool isDense = false}) {
    return InputDecoration(
      isDense: isDense,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 10, vertical: isDense ? 8 : 12),
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
        borderSide: const BorderSide(color: Colors.blue, width: 1),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      );

  Widget _counterField(
      TextEditingController controller, VoidCallback onChanged) {
    return Container(
      decoration: _boxDecoration(),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () {
              int val = int.tryParse(controller.text) ?? 0;
              if (val > 0) {
                controller.text = (val - 1).toString();
                onChanged();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              int val = int.tryParse(controller.text) ?? 0;
              controller.text = (val + 1).toString();
              onChanged();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _addWorkSiteDialog(BuildContext context) {
    if (_selectedCustomerId == null) {
      Common.toastMessaage('Please select a customer first', Colors.red);
      return;
    }
    TextEditingController locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool adding = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Work Site'),
              content: TextFormField(
                controller: locationController,
                decoration:
                    _inputDecoration().copyWith(hintText: 'Work Site Name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (locationController.text.trim().isEmpty) {
                      Common.toastMessaage('Name required', Colors.red);
                      return;
                    }
                    setStateDialog(() => adding = true);
                    final response =
                        await HttpService.addRentalCustomerLocation(
                            _selectedCustomerId!,
                            locationController.text.trim());
                    setStateDialog(() => adding = false);
                    if (response != null && response['status'] == true) {
                      Common.toastMessaage(
                          'Work Site added successfully', Colors.green);
                      Navigator.pop(context);
                      await _loadCustomerLocations(_selectedCustomerId!);
                    } else {
                      Common.toastMessaage(
                          response?['message'] ?? 'Failed', Colors.red);
                    }
                  },
                  child: adding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addCollectedStaffDialog(BuildContext context) {
    if (_selectedCustomerId == null) {
      Common.toastMessaage('Please select a customer first', Colors.red);
      return;
    }
    TextEditingController staffController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool adding = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Customer Staff'),
              content: TextFormField(
                controller: staffController,
                decoration: _inputDecoration().copyWith(hintText: 'Staff Name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (staffController.text.trim().isEmpty) {
                      Common.toastMessaage('Name required', Colors.red);
                      return;
                    }
                    setStateDialog(() => adding = true);
                    final response = await HttpService.addRentalCollectedStaff(
                        _selectedCustomerId!, staffController.text.trim());
                    setStateDialog(() => adding = false);
                    if (response != null && response['status'] == true) {
                      Common.toastMessaage(
                          'Staff added successfully', Colors.green);
                      Navigator.pop(context);
                      await _loadCollectedStaffs(_selectedCustomerId!);
                      // Immediately reopen the staff selection dialog so the new staff appears
                      Future.delayed(const Duration(milliseconds: 200), () {
                        _showStaffDialog(context, isPayment: false);
                      });
                    } else {
                      Common.toastMessaage(
                          response?['message'] ?? 'Failed', Colors.red);
                    }
                  },
                  child: adding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<CustomerExp> filtered = _customers
                .where((c) =>
                    c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Customer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton.icon(
                    onPressed: () async {
                      final token = await Common.getSharedPref('token');
                      Navigator.pop(context);
                      final oldCustomerIds =
                          _customers.map((c) => c.id).toSet();
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddClients(token ?? ""),
                        ),
                      );

                      if (result == true || result == false || result == null) {
                        await _loadCustomers();
                      }
                      final newCustomers = _customers
                          .where((c) => !oldCustomerIds.contains(c.id))
                          .toList();

                      if (newCustomers.isNotEmpty) {
                        final latestCustomer = newCustomers.first;
                        setState(() {
                          _selectedCustomerId = latestCustomer.id;
                          _loadCustomerLocations(_selectedCustomerId!);
                          _loadCollectedStaffs(_selectedCustomerId!);
                          _selectedCollectedByStaffId = null;
                          _selectedStaffName = "Select Staff";
                        });

                        // Fetch rental invoice number for the new customer
                        final invoiceRes =
                            await HttpService.generateInvoiceNumberRental(
                                latestCustomer.id);
                        if (invoiceRes != null &&
                            invoiceRes.status &&
                            invoiceRes.data != null) {
                          String rawInvoiceNo = invoiceRes.data!.invoiceNo;
                          String numericInvoiceNo =
                              rawInvoiceNo.replaceFirst(RegExp(r'^#+'), '');
                          setState(() {
                            _invoiceNoController.text = "#$numericInvoiceNo";
                            _rentIssueIdController.text =
                                "#RIN$numericInvoiceNo";
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Customer "${latestCustomer.name}" added and selected'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // User cancelled or back button
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                    label: const Text("Add",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
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
                          prefixIcon: Icon(Icons.search)),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filtered[index].name),
                            onTap: () async {
                              setState(() {
                                _selectedCustomerId = filtered[index].id;
                                _loadCustomerLocations(_selectedCustomerId!);
                                _loadCollectedStaffs(_selectedCustomerId!);
                                _selectedCollectedByStaffId = null;
                                _selectedStaffName = "Select Staff";
                              });
                              Navigator.pop(context);

                              // Fetch rental invoice number
                              final invoiceRes =
                                  await HttpService.generateInvoiceNumberRental(
                                      filtered[index].id);
                              if (invoiceRes != null &&
                                  invoiceRes.status &&
                                  invoiceRes.data != null) {
                                String rawInvoiceNo =
                                    invoiceRes.data!.invoiceNo;
                                // Ensure only one # at the beginning
                                String numericInvoiceNo = rawInvoiceNo
                                    .replaceFirst(RegExp(r'^#+'), '');
                                String formattedInvoiceNo =
                                    "#$numericInvoiceNo";

                                String formattedRentIssueId =
                                    "#RIN$numericInvoiceNo";

                                setState(() {
                                  _invoiceNoController.text =
                                      formattedInvoiceNo;
                                  _rentIssueIdController.text =
                                      formattedRentIssueId;
                                });
                              }
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

  void _showStaffDialog(BuildContext context, {bool isPayment = false}) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Use either general staff or customer-specific staff
            final List<dynamic> sourceList =
                isPayment ? _staffs : _collectedStaffs;

            // Map to a common format for display
            final List<Map<String, String>> displayList = sourceList.map((s) {
              if (s is Staff) {
                return {"id": s.id, "name": s.name};
              } else if (s is rcs.Staff) {
                return {"id": s.id, "name": s.customerStaff};
              }
              return {"id": "", "name": ""};
            }).toList();

            final List<Map<String, String>> filtered = displayList
                .where((s) => s["name"]!
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
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
                                if (isPayment) {
                                  _paymentCollectedByStaffId =
                                      filtered[index]["id"];
                                  _paymentStaffName = filtered[index]["name"];
                                } else {
                                  _selectedCollectedByStaffId =
                                      filtered[index]["id"];
                                  _selectedStaffName = filtered[index]["name"];
                                }
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

  Widget _minimalDateItem(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDateTime(context, controller),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            controller.text.isNotEmpty ? controller.text : "Select",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _minimalDaysItemDays(String label, TextEditingController controller) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
        Text(
          controller.text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isTransparent = false,
  }) {
    return Card(
      elevation: isTransparent ? 0 : 1,
      color: isTransparent ? Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTransparent ? 0 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTransparent)
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
    _remarksController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }
}

class ProductRow {
  final TextEditingController quantityController =
      TextEditingController(text: "1");
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController ratePerDayController = TextEditingController();
  final TextEditingController noOfDaysController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController grossAmountController = TextEditingController();
  final TextEditingController gstPercentController = TextEditingController();
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  String? selectedProductId;
  String? currentStock;
  bool hasGst = false;
  bool isExpanded = false;

  ProductRow();
}
