import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/uploadedQuotationModel.dart';
import 'package:login2/models/lead_management/customerModel.dart';
import 'package:login2/models/lead_management/workOrderIdModel.dart';
import 'package:login2/service/service.dart';
import 'package:dio/dio.dart';

class EditUploadedQuotationPage extends StatefulWidget {
  final String quotationId;
  const EditUploadedQuotationPage({Key? key, required this.quotationId})
      : super(key: key);

  @override
  State<EditUploadedQuotationPage> createState() =>
      _EditUploadedQuotationPageState();
}

class _EditUploadedQuotationPageState extends State<EditUploadedQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  final HttpService _httpService = HttpService();

  final TextEditingController _enquiryDateController = TextEditingController();
  final TextEditingController _quotationIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  List<CustomerDetails> _customers = [];
  List<WorkOrder> _workOrders = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isLoadingCustomers = false;
  bool _isLoadingWorkOrders = false;

  File? _quotationFile;
  String? _currentFileUrl;
  String? _selectedCustomerId;
  String? _selectedWorkOrderId;

  UploadedQuotationModeData? _quotationData;

  @override
  void initState() {
    super.initState();
    _loadQuotationDetails();
    _loadCustomers();
  }

  @override
  void dispose() {
    _enquiryDateController.dispose();
    _quotationIdController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _totalAmountController.dispose();
    _customerNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotationDetails() async {
    try {
      final response =
          await HttpService.getUploadedQuotationDetails(widget.quotationId);

      if (response != null && response.status == "success") {
        setState(() {
          _quotationData = response.data;
          _currentFileUrl = response.data.file;
          _quotationIdController.text = response.data.quoteId;
          _enquiryDateController.text = response.data.enquiryDate;
          _addressController.text = response.data.address;
          _stateController.text = response.data.state;
          _districtController.text = response.data.district;
          _customerNameController.text = response.data.customerName;
          _selectedCustomerId = response.data.customerId;
          _selectedWorkOrderId = response.data.workorderId;
          _totalAmountController.text = response.data.totalAmount;
          if (response.data.customerId.isNotEmpty) {
            _loadWorkOrders(response.data.customerId);
            _loadCustomerDetails(response.data.customerId);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load quotation details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      setState(() => _isLoadingCustomers = false);
    }
  }

  void _showCustomerSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<CustomerDetails> filteredList = List.from(_customers);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text("Select Customer"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = _customers
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
    try {
      setState(() {
        _selectedCustomerId = customer.id;
        _customerNameController.text = customer.name;
        _selectedWorkOrderId = null;
        _workOrders = [];
      });

      await Future.wait([
        _loadWorkOrders(customer.id),
        _loadCustomerDetails(customer.id),
      ]);
    } catch (e) {
      print('Error selecting customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    try {
      final detailsModel = await _httpService.getCustomerDetails(customerId);
      if (detailsModel != null &&
          detailsModel.status == "success" &&
          detailsModel.data.isNotEmpty) {
        final customerData = detailsModel.data.first;

        setState(() {
          _addressController.text = customerData.address;
          _stateController.text = customerData.state;
          _districtController.text = customerData.district;
        });
      }
    } catch (e) {
      print('Error loading customer details: $e');
    }
  }

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
    await showModalBottomSheet(
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
                      await _pickFileAdd();
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.image,
                        color: Theme.of(context).primaryColor),
                    title: const Text('Image',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () async {
                      final file = await _pickImage();
                      if (file != null) {
                        setState(() => _quotationFile = file);
                      }
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
  }

  Future<void> _pickFileAdd() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'doc',
          'docx',
          'xls',
          'xlsx'
        ],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _quotationFile = File(result.files.single.path!);
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

  Future<File?> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  Future<void> _updateQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate customer selection
    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
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
      final token = await Common.getSharedPref('token');

      // Create FormData correctly - don't use fromMap()
      final formData = FormData();

      // Add all fields
      formData.fields.add(MapEntry('token', token ?? ''));
      formData.fields.add(MapEntry('id', widget.quotationId));
      formData.fields.add(MapEntry('customer_id', _selectedCustomerId ?? ''));
      formData.fields
          .add(MapEntry('customer_name', _customerNameController.text));
      formData.fields.add(MapEntry('work_order_id', _selectedWorkOrderId ?? ''));
      formData.fields
          .add(MapEntry('enquiry_date', _enquiryDateController.text));
      formData.fields
          .add(MapEntry('quotation_id', _quotationIdController.text));
      formData.fields.add(MapEntry('address', _addressController.text));
      formData.fields.add(MapEntry('state', _stateController.text));
      formData.fields.add(MapEntry('district', _districtController.text));
      formData.fields
          .add(MapEntry('total_amount', _totalAmountController.text));

      // Add file only if a new one is selected
      if (_quotationFile != null) {
        formData.files.add(MapEntry(
          'quotation_file',
          await MultipartFile.fromFile(
            _quotationFile!.path,
            filename: _quotationFile!.path.split('/').last,
          ),
        ));
      }

      final response = await _httpService.updateUploadedQuotation(formData);

      if (response != null && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Quotation updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to update quotation'),
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
          'Edit Uploaded Quotation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
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
                    controller: _customerNameController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select Customer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      errorText: _selectedCustomerId == null ? 'Please select a customer' : null,
                    ),
                    onTap: () {
                      if (_customers.isNotEmpty) {
                        _showCustomerSearchDialog();
                      }
                    },
                    validator: (value) {
                      if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
                        return 'Please select a customer';
                      }
                      return null;
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
                  'Work Order ID',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _selectedCustomerId == null
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
                            value: _selectedWorkOrderId,
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
                                _selectedWorkOrderId = value;
                              });
                            },
                          ),

            const SizedBox(height: 20),

            // Enquiry Date and Quotation ID in row
            Row(
              children: [
                // Enquiry Date
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
                const SizedBox(width: 16),

                // Quotation ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.numbers_outlined,
                              size: 20, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Quotation ID',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quotationIdController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Quotation ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
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
                            'State *',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stateController,
                        decoration: InputDecoration(
                          hintText: 'Enter state',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter state';
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
                            'District *',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _districtController,
                        decoration: InputDecoration(
                          hintText: 'Enter district',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter district';
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
                  'Quotation File',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentFileUrl != null && _currentFileUrl!.isNotEmpty)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentFileUrl!.split('/').last,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Current uploaded file',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                ],
              ),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _quotationFile != null
                        ? Colors.green
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _quotationFile != null
                          ? Icons.check_circle
                          : Icons.cloud_upload,
                      size: 48,
                      color: _quotationFile != null
                          ? Colors.green
                          : const Color.fromARGB(255, 22, 145, 216),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _quotationFile != null
                          ? _quotationFile!.path.split('/').last
                          : 'Tap to upload new file',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: _quotationFile != null
                            ? Colors.green
                            : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _quotationFile != null
                          ? 'Tap to change file'
                          : 'Leave empty to keep current file',
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
                  'Total Amount',
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
        onPressed: _isSubmitting ? null : _updateQuotation,
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
            : const Text(
                'Update Quotation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}