import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/lead_management/customerModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/quotation_uploadform_model.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/lead_management/workOrderIdModel.dart';
import 'package:login2/service/service.dart';
import 'package:dio/dio.dart';
import 'package:login2/widgets/quick_add_customer_dialog.dart';

class UploadQuotationPage extends StatefulWidget {
  const UploadQuotationPage({Key? key}) : super(key: key);

  @override
  State<UploadQuotationPage> createState() => _UploadQuotationPageState();
}

class _UploadQuotationPageState extends State<UploadQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  final HttpService _httpService = HttpService();
  final TextEditingController _enquiryDateController = TextEditingController();
  final TextEditingController _quotationIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController _customerCtrl =
      TextEditingController(); // Added for searchable dropdown
  List<CustomerDetails> _customers = [];
  List<WorkOrder> _workOrders = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingCustomers = true;
  bool _isLoadingWorkOrders = false;
  bool isLoadingState = true;
  bool isLoadingDistrict = false;
  StateModel? stateModel;
  List<StateList> stateList = [];
  String? selectedStateId;
  String? selectedStateName;

  DistrictModel? districtModel;
  List<DistrictList> districtList = [];
  String? selectedDistrictId;
  String? selectedDistrictName;
  QuotationFormData _formData = QuotationFormData();
  bool _isRefreshingCustomers = false;
  late Future<CustomerExpenseListModel?> customersFuture;
  String? token;
  @override
  void initState() {
    super.initState();
    _enquiryDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
    _getStates();
    _loadCustomers();
    _loadToken();
  }

  @override
  void dispose() {
    _enquiryDateController.dispose();
    _quotationIdController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _totalAmountController.dispose();
    _remarksController.dispose();
    _customerCtrl.dispose();
    nationalityController.dispose();
    super.dispose();
  }

  Future<void> _getStates() async {
    setState(() => isLoadingState = true);
    final response = await HttpService.getState();
    if (response != null && response.status == true) {
      setState(() {
        stateList = response.data;
        isLoadingState = false;
      });
    } else {
      setState(() => isLoadingState = false);
    }
  }

  Future<void> _getDistricts(String stateId) async {
    setState(() {
      isLoadingDistrict = true;
    });

    final response = await HttpService.getDistrict(stateId);
    if (response != null && response.status == true) {
      setState(() {
        districtList = response.data;
        isLoadingDistrict = false;
      });
    } else {
      setState(() => isLoadingDistrict = false);
    }
  }

  Future<void> _loadToken() async {
    token = await Common.getSharedPref("token");
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    final customerModel = await HttpService.getCustomerList();
    if (customerModel != null && customerModel.status == "success") {
      setState(() {
        _customers = customerModel.data;
        _isLoadingCustomers = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load customers'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoadingCustomers = false);
    }
  }

  Future<void> _onCustomerSelected(String? customerId) async {
    if (customerId == null) return;

    final selectedCustomer = _customers.firstWhere(
      (c) => c.id == customerId,
    );

    setState(() {
      _formData = _formData.copyWith(
        customerId: customerId,
        customerName: selectedCustomer.name,
        contactNo: selectedCustomer.contactNo,
        emailId: selectedCustomer.emailId,
      );
      _workOrders = [];
      _formData = _formData.copyWith(workOrderId: null);
    });

    await Future.wait([
      _loadWorkOrders(customerId),
      _loadCustomerDetails(customerId),
    ]);
  }

  Future<void> _refreshAfterCustomerAdded() async {
    setState(() {
      _isRefreshingCustomers = true;
    });

    try {
      // Refresh customer list
      customersFuture = HttpService.getCustomers();
      setState(() {});

      if (mounted) {
        Common.toastMessaage('Customer added successfully', Colors.green);
      }
    } catch (e) {
      log("Error refreshing customers: $e");
      if (mounted) {
        Common.toastMessaage('Failed to refresh customers', Colors.red);
      }
    } finally {
      setState(() {
        _isRefreshingCustomers = false;
      });
    }
  }

  Future<void> _loadWorkOrders(String customerId) async {
    setState(() => _isLoadingWorkOrders = true);
    final workOrderModel = await _httpService.getWorkorderId(customerId);
    if (workOrderModel != null && workOrderModel.status == "success") {
      setState(() {
        _workOrders = workOrderModel.data ?? [];
        _isLoadingWorkOrders = false;
      });
    } else {
      setState(() => _isLoadingWorkOrders = false);
    }
  }

  Future<void> _loadCustomerDetails(String customerId) async {
    final detailsModel = await _httpService.getCustomerDetails(customerId);
    if (detailsModel != null &&
        detailsModel.status == "success" &&
        detailsModel.data.isNotEmpty) {
      final customerData = detailsModel.data.first;
      _addressController.text = customerData.address;
      nationalityController.text = customerData.nationality;
      final stateIdFromApi = customerData.state;
      final districtIdFromApi = customerData.district;
      if (stateIdFromApi.isNotEmpty && stateIdFromApi != "0") {
        String? stateName;
        if (stateList.isNotEmpty) {
          final matchedState = stateList.firstWhere(
            (state) => state.id == stateIdFromApi,
            orElse: () => StateList(id: '', name: ''),
          );
          stateName = matchedState.name;
        }

        if (stateIdFromApi != selectedStateId) {
          await _getDistricts(stateIdFromApi);
        }
        setState(() {
          _formData = _formData.copyWith(
            address: customerData.address,
            state: stateIdFromApi,
            district: districtIdFromApi,
            postOffice: customerData.postOffice,
            pincode: customerData.pincode,
            nationality: customerData.nationality,
          );
          selectedStateId = stateIdFromApi;
          selectedStateName = stateName ?? stateIdFromApi;
        });
      }
      if (districtIdFromApi.isNotEmpty && districtIdFromApi != "0") {
        String? districtName;
        if (districtList.isNotEmpty) {
          final matchedDistrict = districtList.firstWhere(
            (district) => district.id == districtIdFromApi,
            orElse: () => DistrictList(id: '', name: ''),
          );
          districtName = matchedDistrict.name;
        }

        setState(() {
          selectedDistrictId = districtIdFromApi;
          selectedDistrictName = districtName ?? districtIdFromApi;
        });
      }
    }
  }

  // Future<void> _loadCustomerDetails(String customerId) async {
  //   final detailsModel = await _httpService.getCustomerDetails(customerId);
  //   if (detailsModel != null &&
  //       detailsModel.status == "success" &&
  //       detailsModel.data.isNotEmpty) {
  //     final customerData = detailsModel.data.first;
  //     _addressController.text = customerData.address;
  //     nationalityController.text = customerData.nationality;
  //     final stateIdFromApi = customerData.state;
  //     final districtIdFromApi = customerData.district;
  //     String? stateName;
  //     if (stateIdFromApi.isNotEmpty && stateList.isNotEmpty) {
  //       final matchedState = stateList.firstWhere(
  //         (state) => state.id == stateIdFromApi,
  //         orElse: () => StateList(id: '', name: ''),
  //       );
  //       stateName = matchedState.name;
  //     }
  //     if (stateIdFromApi.isNotEmpty && stateIdFromApi != selectedStateId) {
  //       await _getDistricts(stateIdFromApi);
  //     }
  //     String? districtName;
  //     if (districtIdFromApi.isNotEmpty && districtList.isNotEmpty) {
  //       final matchedDistrict = districtList.firstWhere(
  //         (district) => district.id == districtIdFromApi,
  //         orElse: () => DistrictList(id: '', name: ''),
  //       );
  //       districtName = matchedDistrict.name;
  //     }

  //     setState(() {
  //       _formData = _formData.copyWith(
  //         address: customerData.address,
  //         state: stateIdFromApi,
  //         district: districtIdFromApi,
  //         postOffice: customerData.postOffice,
  //         pincode: customerData.pincode,
  //         nationality: customerData.nationality,
  //       );
  //       selectedStateId = stateIdFromApi;
  //       selectedStateName = stateName ?? stateIdFromApi;
  //       selectedDistrictId = districtIdFromApi;
  //       selectedDistrictName = districtName ?? districtIdFromApi;
  //     });
  //   }
  // }

  Future<bool?> _showQuickAddCustomerDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: QuickAddCustomerDialog(
            token: token ?? '',
            onCustomerAdded: (success) async {
              if (success) {
                Navigator.pop(context, true);
              }
            },
          ),
        );
      },
    );
  }

  // Update the type in _showCustomerSearchDialog to use CustomerDetails
  void _showCustomerSearchDialog(List<CustomerDetails> customers) {
    FocusNode searchFocusNode = FocusNode();
    bool shouldAutoFocus = true;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<CustomerDetails> filteredList = List.from(customers);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (shouldAutoFocus) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  FocusScope.of(context).requestFocus(searchFocusNode);
                }
              });
            }
            return AlertDialog(
              scrollable: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Customer"),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue, size: 24),
                    onPressed: () async {
                      shouldAutoFocus = false;
                      final result = await _showQuickAddCustomerDialog(context);
                      if (result != null && result) {
                        Navigator.pop(context);
                        await _refreshAfterCustomerAdded();
                      } else {
                        shouldAutoFocus = true;
                        if (mounted) {
                          _showCustomerSearchDialog(customers);
                        }
                      }
                      // final result = await _showQuickAddCustomerDialog(context);
                      // if (result != null && result) {
                      //   await _refreshAfterCustomerAdded();
                      //   // Re-open the dialog with updated list
                      //   if (mounted) {
                      //     Navigator.pop(context);
                      //     _showCustomerSearchDialog(customers);
                      //   }
                      // }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      focusNode: searchFocusNode,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = customers
                              .where((c) => c.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search customer",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No customers found"))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final cust = filteredList[index];
                                return InkWell(
                                  onTap: () {
                                    _handleCustomerSelection(cust);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      cust.name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
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

  Future<void> _handleCustomerSelection(CustomerDetails customer) async {
    setState(() {
      _formData = _formData.copyWith(
        customerId: customer.id,
        customerName: customer.name,
        contactNo: customer.contactNo,
        emailId: customer.emailId,
      );
      _customerCtrl.text = customer.name; // Set the selected customer name
      _workOrders = [];
      _formData = _formData.copyWith(workOrderId: null);

      // Clear address fields until new data loads
      _addressController.clear();
      _stateController.clear();
      _districtController.clear();
    });

    await Future.wait([
      _loadWorkOrders(customer.id),
      _loadCustomerDetails(customer.id),
    ]);
  }

  // ... [Keep all other methods like _selectDate, _pickFile, _pickFileAdd, _submitQuotation unchanged] ...

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _enquiryDateController.text =
            DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.document_scanner,
                        color: Theme.of(context).primaryColor),
                    title: const Text('Document',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () async {
                      final file = await _pickFileAdd();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Cancel',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _formData = _formData.copyWith(quotationFile: result);
      });
    }
  }

  Future<void> _pickFileAdd() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _formData = _formData.copyWith(
            quotationFile: File(result.files.single.path!),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File pick error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_formData.quotationFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a quotation file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate customer selection
    if (_formData.customerId == null || _formData.customerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a customer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final formDataToSend = FormData.fromMap({
        'customer_id': _formData.customerId ?? '',
        'customer_name': _formData.customerName ?? '',
        'work_order_id': _formData.workOrderId ?? '',
        'enquiry_date': _enquiryDateController.text,
        'quotation_id': _quotationIdController.text,
        'address': _addressController.text,
        'state': selectedStateId ?? '',
        'district': selectedDistrictId ?? '',
        'state_name': selectedStateName ?? '',
        'district_name': selectedDistrictName ?? '',
        // 'state': _stateController.text,
        // 'district': _districtController.text,
        'total_amount': _totalAmountController.text,
        'contact_no': _formData.contactNo ?? '',
        'email_id': _formData.emailId ?? '',
        'post_office': _formData.postOffice ?? '',
        'pincode': _formData.pincode ?? '',
        'nationality': _formData.nationality ?? '',
      });

      if (_formData.quotationFile != null) {
        formDataToSend.files.add(MapEntry(
          'quotation_file',
          await MultipartFile.fromFile(
            _formData.quotationFile!.path,
            filename: _formData.quotationFile!.path.split('/').last,
          ),
        ));
      }

      final response = await _httpService.importQuotation(formDataToSend);
      if (response != null && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Quotation uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to upload quotation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Upload Quotation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Customer Details'),
                    _buildCustomerSelectionCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Work Order & Dates'),
                    _buildWorkOrderAndDateSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Address Details'),
                    _buildAddressSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Financial Details'),
                    _buildFinancialSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Quotation File'),
                    _buildFileUploadSection(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCustomerSelectionCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Customer *',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _isLoadingCustomers
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : TextFormField(
                    controller: _customerCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select Customer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      errorText: _formData.customerId == null
                          ? 'Please select a customer'
                          : null,
                    ),
                    onTap: () {
                      if (_customers.isNotEmpty) {
                        _showCustomerSearchDialog(_customers);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOrderAndDateSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Work Order ID
            Row(
              children: [
                Icon(Icons.work_outline,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Work Order ID *',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _formData.customerId == null
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Text(
                        'Select a customer first',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : _isLoadingWorkOrders
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : _workOrders.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.amber, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No work orders found for this customer',
                                    style: TextStyle(color: Colors.amber),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _formData.workOrderId,
                            decoration: InputDecoration(
                              hintText: 'Select Work Order',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            items: _workOrders.map((workOrder) {
                              return DropdownMenuItem<String>(
                                value: workOrder.workOrderId,
                                child: Text(
                                  'Work Order #${workOrder.workOrderId}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _formData =
                                    _formData.copyWith(workOrderId: value);
                              });
                            },
                            validator: (value) {
                              if (_workOrders.isNotEmpty &&
                                  (value == null || value.isEmpty)) {
                                return 'Please select a work order';
                              }
                              return null;
                            },
                          ),

            const SizedBox(height: 20),

            // Enquiry Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 20, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Enquiry Date *',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _enquiryDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDate,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select enquiry date';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Address *',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter full address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                // State Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag_outlined,
                              size: 20, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'State',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      isLoadingState
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: (selectedStateId == null ||
                                      selectedStateId == "0" ||
                                      selectedStateId!.isEmpty)
                                  ? null
                                  : selectedStateId,
                              hint: const Text("Select State"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("Select State"),
                                ),
                                ...stateList.map((state) {
                                  return DropdownMenuItem<String>(
                                    value: state.id,
                                    child: Text(state.name),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedStateId = value;
                                  if (value != null) {
                                    final state = stateList.firstWhere(
                                      (s) => s.id == value,
                                      orElse: () => StateList(id: '', name: ''),
                                    );
                                    if (state.id.isNotEmpty) {
                                      selectedStateName = state.name;
                                    }
                                  } else {
                                    selectedStateName = null;
                                  }
                                  selectedDistrictId = null;
                                  selectedDistrictName = null;
                                  districtList.clear();
                                });
                                if (value != null) _getDistricts(value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select state';
                                }
                                return null;
                              },
                            ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.map_outlined,
                              size: 20, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'District',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      isLoadingDistrict
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: (selectedDistrictId == null ||
                                      selectedDistrictId == "0" ||
                                      selectedDistrictId!.isEmpty)
                                  ? null
                                  : selectedDistrictId,
                              hint: const Text("Select District"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("Select District"),
                                ),
                                ...districtList.map((district) {
                                  return DropdownMenuItem<String>(
                                    value: district.id,
                                    child: Text(district.name),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedDistrictId = value;
                                  if (value != null) {
                                    final district = districtList.firstWhere(
                                      (d) => d.id == value,
                                      orElse: () =>
                                          DistrictList(id: '', name: ''),
                                    );
                                    if (district.id.isNotEmpty) {
                                      selectedDistrictName = district.name;
                                    }
                                  } else {
                                    selectedDistrictName = null;
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select district';
                                }
                                return null;
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),

            // // Nationality field
            // const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Icon(Icons.flag_outlined,
            //         size: 20, color: Theme.of(context).primaryColor),
            //     const SizedBox(width: 8),
            //     const Text(
            //       'Nationality',
            //       style: TextStyle(
            //         fontWeight: FontWeight.w500,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            // TextFormField(
            //   controller: nationalityController,
            //   decoration: InputDecoration(
            //     hintText: 'Enter nationality',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     contentPadding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            //   ),
            // ),

            // Customer contact info (read-only)
            if (_formData.customerId != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.contact_phone_outlined,
                      size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Customer Contact',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  if (_formData.contactNo != null &&
                      _formData.contactNo!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.phone, size: 14),
                      label: Text(_formData.contactNo!),
                      backgroundColor: Colors.grey[100],
                    ),
                  if (_formData.emailId != null &&
                      _formData.emailId!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.email, size: 14),
                      label: Text(_formData.emailId!),
                      backgroundColor: Colors.grey[100],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Upload Quotation File *',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _formData.quotationFile != null
                        ? Colors.green
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _formData.quotationFile != null
                          ? Icons.check_circle
                          : Icons.cloud_upload,
                      size: 48,
                      color: _formData.quotationFile != null
                          ? Colors.green
                          : const Color.fromARGB(255, 22, 145, 216),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formData.quotationFile != null
                          ? _formData.quotationFile!.path.split('/').last
                          : 'Tap to upload quotation file',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: _formData.quotationFile != null
                            ? Colors.green
                            : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formData.quotationFile != null
                          ? 'Tap to change file'
                          : 'Supported formats: PDF',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (_formData.quotationFile != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[800],
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Change File'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on_outlined,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Total Amount *',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _totalAmountController,
              decoration: InputDecoration(
                hintText: 'Enter total amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitQuotation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 22, 145, 216),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Upload Quotation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
