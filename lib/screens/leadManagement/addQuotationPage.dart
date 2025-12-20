import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/customerModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/quotationDetailsModel.dart'
    as details;
import 'package:login2/models/lead_management/quotationTemplateModel.dart';
import 'package:login2/models/lead_management/workOrderIdModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/quick_add_customer_dialog.dart';

class AddQuotationPage extends StatefulWidget {
  const AddQuotationPage({Key? key}) : super(key: key);
  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomer;
  String? selectedWorkOrder;
  String? selectedTemplate;
  String? token;
  String quotationId = "#QUO122";
  String selectedRateType = "Fixed Rate";
  CustomerModel? _customerModel;
  QuotationTemplateModel? _templateModel;
  details.QuotationTemplateDetailsModel? _templateDetailsModel;
  CustomerWorkDetailsModel? _workOrderModel;
  String? selectedTemplateId;
  String? selectedCustomerId;
  bool isLoadingCustomers = false;
  bool isLoadingTemplates = false;
  final TextEditingController customerNameCtrl = TextEditingController();
  final TextEditingController templateCtrl = TextEditingController();
  final TextEditingController materialCtrl = TextEditingController();
  final TextEditingController enquiryDateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  List<MaterialData> materials = [];
  List<ProductRow> productRows = [];
  bool isLoadingMaterials = true;
  bool _isRefreshingCustomers = false;

  // State and District related variables
  StateModel? stateModel;
  List<StateList> stateList = [];
  String? selectedStateId;
  String? selectedStateName;

  DistrictModel? districtModel;
  List<DistrictList> districtList = [];
  String? selectedDistrictId;
  String? selectedDistrictName;

  bool isLoadingState = true;
  bool isLoadingDistrict = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
    _loadCustomers();
    _loadTemplates();
    _loadToken();
    _getStates();
  }

  Future<void> _loadMaterials() async {
    setState(() => isLoadingMaterials = true);
    final httpService = HttpService();
    final materialList = await httpService.getMaterials();
    if (materialList != null && materialList.data != null) {
      setState(() {
        materials = materialList.data!;
        isLoadingMaterials = false;
      });
    } else {
      setState(() => isLoadingMaterials = false);
      log("No materials found or API error");
    }
  }

  Future<void> _loadCustomers({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => isLoadingCustomers = true);
    }

    final customerList = await HttpService.getCustomerList();
    if (customerList != null && customerList.data.isNotEmpty) {
      setState(() {
        _customerModel = customerList;
        isLoadingCustomers = false;
      });
    } else {
      setState(() => isLoadingCustomers = false);
      log("No customers found or API error");
    }
  }

  Future<void> _loadToken() async {
    token = await Common.getSharedPref("token");
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
      districtList = [];
      selectedDistrictId = null;
      selectedDistrictName = null;
      districtController.clear();
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

  Future<void> _submitQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final httpService = HttpService();
      final templateFields = _templateDetailsModel?.data?.fields
              ?.map(
                (field) => ({
                  "field_name": field.fieldName ?? '',
                  "field_value": field.fieldData ?? '',
                }),
              )
              .toList() ??
          [];
      final productList = productRows.map((row) {
        return {
          "material_id": row.materialData?.materialId ?? '',
          "material_name": row.materialData?.materialName ?? '',
          "quantity": row.quantityController.text,
          "rate": row.rateController.text,
          "gst": row.gstController.text,
          "total": _calculateSubTotal(
            productRows.indexOf(row),
          ).toStringAsFixed(2),
          "unit": row.materialData?.unitName ?? '',
        };
      }).toList();
      final formData = FormData.fromMap({
        "customer_id": selectedCustomerId ?? '',
        "work_order_id": selectedWorkOrder ?? '',
        "quotation_id": quotationId,
        "enquiry_date": enquiryDateController.text,
        "rate_type": selectedRateType,
        "address": addressController.text,
        "district": selectedDistrictId ?? '',
        "district_name": selectedDistrictName ?? districtController.text,
        "state": selectedStateId ?? '',
        "state_name": selectedStateName ?? stateController.text,
        "nationality": nationalityController.text,
        "template_id": selectedTemplateId ?? '',
        "template_fields": jsonEncode(templateFields),
        "products": jsonEncode(productList),
      });

      final response = await httpService.submitQuotation(formData);

      if (response != null && response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Quotation submitted successfully!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?["message"] ?? "Submission failed",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e, stack) {
      log("Quotation submission error: $e");
      log(stack.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "An error occurred while submitting",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _loadTemplates() async {
    setState(() => isLoadingTemplates = true);

    final httpService = HttpService();
    final templateList = await httpService.getTemplateList();

    if (templateList != null && templateList.data.isNotEmpty) {
      setState(() {
        _templateModel = templateList;
        isLoadingTemplates = false;
      });
    } else {
      setState(() => isLoadingTemplates = false);
      log("No templates found or API error");
    }
  }

  Future<void> _loadTemplateDetails(String templateId) async {
    setState(() => isLoadingTemplates = true);
    final httpService = HttpService();
    final templateDetails = await httpService.getTemplateDetails(templateId);
    if (templateDetails != null &&
        templateDetails.data != null &&
        (templateDetails.data!.fields?.isNotEmpty ?? false)) {
      setState(() {
        _templateDetailsModel =
            templateDetails as details.QuotationTemplateDetailsModel;
        isLoadingTemplates = false;
      });
    } else {
      setState(() => isLoadingTemplates = false);
      log("No template details found or API error");
    }
  }

 Future<void> _loadCustomerDetails(String customerId) async {
  if (customerId.isEmpty) return;

  try {
    final httpService = HttpService();
    final customerDetails = await httpService.getCustomerDetails(customerId);

    if (customerDetails != null &&
        customerDetails.data.isNotEmpty &&
        customerDetails.status == "success") {
      final customerData = customerDetails.data.first;

      // The API returns IDs, not names
      final stateIdFromApi = customerData.state; // This is actually state ID
      final districtIdFromApi = customerData.district; // This is actually district ID

      // Find state name from stateList using the ID
      String? stateName;
      if (stateIdFromApi.isNotEmpty && stateList.isNotEmpty) {
        final matchedState = stateList.firstWhere(
          (state) => state.id == stateIdFromApi,
          orElse: () => StateList(id: '', name: ''),
        );
        stateName = matchedState.name;
      }

      // If state is found, load districts for that state
      if (stateIdFromApi.isNotEmpty && stateIdFromApi != selectedStateId) {
        await _getDistricts(stateIdFromApi);
        
        // Wait a bit for districts to load
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Find district name from districtList using the ID
      String? districtName;
      if (districtIdFromApi.isNotEmpty && districtList.isNotEmpty) {
        final matchedDistrict = districtList.firstWhere(
          (district) => district.id == districtIdFromApi,
          orElse: () => DistrictList(id: '', name: ''),
        );
        districtName = matchedDistrict.name;
      }

      setState(() {
        addressController.text = customerData.address;
        nationalityController.text = customerData.nationality;
        
        // Set state dropdown
        if (stateIdFromApi.isNotEmpty) {
          selectedStateId = stateIdFromApi;
          selectedStateName = stateName ?? stateIdFromApi; // Fallback to ID if name not found
          stateController.text = stateName ?? stateIdFromApi;
        } else {
          selectedStateId = null;
          selectedStateName = null;
          stateController.clear();
        }
        
        // Set district dropdown
        if (districtIdFromApi.isNotEmpty) {
          selectedDistrictId = districtIdFromApi;
          selectedDistrictName = districtName ?? districtIdFromApi; // Fallback to ID if name not found
          districtController.text = districtName ?? districtIdFromApi;
        } else {
          selectedDistrictId = null;
          selectedDistrictName = null;
          districtController.clear();
        }
      });

      // Log for debugging
      log("Customer Details: State ID: $stateIdFromApi, District ID: $districtIdFromApi");
      log("State Name: $stateName, District Name: $districtName");
      
    } else {
      setState(() {
        addressController.clear();
        districtController.clear();
        stateController.clear();
        nationalityController.clear();
        selectedStateId = null;
        selectedDistrictId = null;
        selectedStateName = null;
        selectedDistrictName = null;
        districtList.clear();
      });
    }
  } catch (e, stack) {
    log("Customer details loading error: $e");
    log(stack.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to load customer details")),
    );
  }
}

  Future<void> _loadWorkOrderId(String customerId) async {
    setState(() => isLoadingTemplates = true);

    final httpService = HttpService();
    final workOrderResponse = await httpService.getWorkorderId(customerId);

    if (workOrderResponse != null &&
        (workOrderResponse.data?.isNotEmpty ?? false)) {
      setState(() {
        _workOrderModel = workOrderResponse;
        workOrders =
            workOrderResponse.data!.map((e) => e.workOrderId ?? "").toList();
        isLoadingTemplates = false;
      });
    } else {
      setState(() => isLoadingTemplates = false);
      log("No work order IDs found or API error");
    }
  }

  final addressController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final nationalityController = TextEditingController();
  var workOrders = ["No Work Order ID"];

  void _addProductRow() {
    setState(() {
      productRows.add(
        ProductRow(
          materialData: null,
          quantityController: TextEditingController(text: '1'),
          rateController: TextEditingController(text: '0.00'),
          gstController: TextEditingController(text: '0'),
          rateType: selectedRateType,
          materialCtrl: TextEditingController(text: 'Select Item'),
        ),
      );
    });
  }

  void _removeProductRow(int index) {
    setState(() {
      productRows.removeAt(index);
    });
  }

  double _calculateTotal(int index) {
    final row = productRows[index];
    double quantity = double.tryParse(row.quantityController.text) ?? 0.0;
    double rate = double.tryParse(row.rateController.text) ?? 0.0;
    return quantity * rate;
  }

  double _calculateSubTotal(int index) {
    final total = _calculateTotal(index);
    double gst = double.tryParse(productRows[index].gstController.text) ?? 0.0;
    return total + (total * gst / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Quotation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
      ),
      body: _isRefreshingCustomers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Customer Details"),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Customer Name",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: customerNameCtrl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Select Customer",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                ),
                                validator: (_) => selectedCustomerId == null
                                    ? "Required"
                                    : null,
                                onTap: () {
                                  _showCustomerSearchDialog(
                                      _customerModel?.data ?? []);
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Work Order Id",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                hint: const Text("Select Work Order ID"),
                                value: selectedWorkOrder,
                                isExpanded: true,
                                items: workOrders
                                    .map(
                                      (wo) => DropdownMenuItem(
                                        value: wo,
                                        child: Text(wo),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => selectedWorkOrder = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _datePickerField(
                            label: "Enquiry Date *",
                            controller: enquiryDateController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // State Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "State *",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              isLoadingState
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : DropdownButtonFormField<String>(
                                      value: selectedStateId,
                                      hint: const Text("Select State"),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                      ),
                                      validator: (_) => selectedStateId == null
                                          ? "Required"
                                          : null,
                                      items: stateList.map((state) {
                                        return DropdownMenuItem<String>(
                                          value: state.id,
                                          child: Text(state.name),
                                          onTap: () {
                                            setState(() {
                                              selectedStateName = state.name;
                                              stateController.text = state.name;
                                            });
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStateId = value;
                                          if (value != null) {
                                            // Find state name
                                            final state = stateList.firstWhere(
                                              (s) => s.id == value,
                                              orElse: () =>
                                                  StateList(id: '', name: ''),
                                            );
                                            if (state.id.isNotEmpty) {
                                              selectedStateName = state.name;
                                              stateController.text = state.name;
                                            }
                                          } else {
                                            selectedStateName = null;
                                            stateController.clear();
                                          }
                                          // Clear district when state changes
                                          selectedDistrictId = null;
                                          selectedDistrictName = null;
                                          districtController.clear();
                                          districtList.clear();
                                        });
                                        if (value != null) _getDistricts(value);
                                      },
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // District Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "District *",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              isLoadingDistrict
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : DropdownButtonFormField<String>(
                                      value: selectedDistrictId,
                                      hint: const Text("Select District"),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                      ),
                                      validator: (_) =>
                                          selectedDistrictId == null
                                              ? "Required"
                                              : null,
                                      items: districtList.map((district) {
                                        return DropdownMenuItem<String>(
                                          value: district.id,
                                          child: Text(district.name),
                                          onTap: () {
                                            setState(() {
                                              selectedDistrictName =
                                                  district.name;
                                              districtController.text =
                                                  district.name;
                                            });
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDistrictId = value;
                                          if (value != null) {
                                            // Find district name
                                            final district =
                                                districtList.firstWhere(
                                              (d) => d.id == value,
                                              orElse: () => DistrictList(
                                                  id: '', name: ''),
                                            );
                                            if (district.id.isNotEmpty) {
                                              selectedDistrictName =
                                                  district.name;
                                              districtController.text =
                                                  district.name;
                                            }
                                          } else {
                                            selectedDistrictName = null;
                                            districtController.clear();
                                          }
                                        });
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            label: "Address",
                            controller: addressController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            label: "Nationality",
                            controller: nationalityController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _sectionTitle("Choose Template", color: Colors.deepOrange),
                    const SizedBox(height: 10),

                    // Searchable Template Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Template",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _templateDropdown(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Display Template Fields Dynamically ---
                    if (_templateDetailsModel != null &&
                        _templateDetailsModel!.data != null &&
                        (_templateDetailsModel!.data!.fields?.isNotEmpty ??
                            false))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Template Fields",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._templateDetailsModel!.data!.fields!
                                    .map((field) {
                                  final controller = TextEditingController(
                                    text: field.fieldData ?? "",
                                  );

                                  bool isNonEditable = false;
                                  if (field.fieldId != null) {
                                    if (field.fieldId is String) {
                                      isNonEditable = field.fieldId == "1" ||
                                          field.fieldId == "2";
                                    } else if (field.fieldId is int) {
                                      isNonEditable = field.fieldId == 1 ||
                                          field.fieldId == 2;
                                    }
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              field.fieldName ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: isNonEditable
                                                    ? Colors.grey.shade600
                                                    : Colors.black,
                                              ),
                                            ),
                                            if (field.isRequired ??
                                                true && !isNonEditable)
                                              const Text(
                                                " *",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            if (isNonEditable)
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  "(Read Only)",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: isNonEditable ? 40 : 120,
                                          child: TextFormField(
                                            controller: controller,
                                            maxLines: isNonEditable ? 1 : 5,
                                            minLines: 1,
                                            readOnly: isNonEditable,
                                            decoration: InputDecoration(
                                              hintText: isNonEditable
                                                  ? "This field cannot be edited"
                                                  : "Enter ${field.fieldName}",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical:
                                                    isNonEditable ? 8 : 12,
                                              ),
                                              filled: isNonEditable,
                                              fillColor: Colors.grey.shade100,
                                            ),
                                            style: TextStyle(
                                              color: isNonEditable
                                                  ? Colors.grey.shade700
                                                  : Colors.black,
                                            ),
                                            onChanged: isNonEditable
                                                ? null
                                                : (val) {
                                                    field.fieldData = val;
                                                  },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      )
                    else if (isLoadingTemplates)
                      const Center(child: CircularProgressIndicator())
                    else
                      const SizedBox(),

                    _sectionTitle("Package Details"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rate Type",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(
                                      () => selectedRateType = "Fixed Rate"),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selectedRateType == "Fixed Rate"
                                          ? const Color(0xFF2732C2)
                                              .withOpacity(0.1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: selectedRateType == "Fixed Rate"
                                            ? const Color(0xFF2732C2)
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          selectedRateType == "Fixed Rate"
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color:
                                              selectedRateType == "Fixed Rate"
                                                  ? const Color(0xFF2732C2)
                                                  : Colors.grey,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Fixed Rate",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() =>
                                      selectedRateType = "Unit Based Rate"),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedRateType == "Unit Based Rate"
                                              ? const Color(0xFF2732C2)
                                                  .withOpacity(0.1)
                                              : Colors.white,
                                      border: Border.all(
                                        color: selectedRateType ==
                                                "Unit Based Rate"
                                            ? const Color(0xFF2732C2)
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          selectedRateType == "Unit Based Rate"
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: selectedRateType ==
                                                  "Unit Based Rate"
                                              ? const Color(0xFF2732C2)
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Unit Based Rate",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _sectionTitle("Products", color: Colors.teal),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 800,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _productHeader(),
                                  const Divider(),
                                  ...productRows.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final row = entry.value;
                                    return _productRow(index, row);
                                  }).toList(),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _addProductRow,
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add New"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _submitQuotation,
                        icon: const Icon(Icons.check),
                        label: const Text("Create"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2732C2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _templateDropdown() {
    if (_templateModel == null || _templateModel!.data.isEmpty) {
      return TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: "Select Template",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_drop_down),
          ),
        ),
        controller: TextEditingController(
          text: isLoadingTemplates
              ? "Loading templates..."
              : "No templates available",
        ),
      );
    }

    return TextFormField(
      controller: templateCtrl,
      readOnly: true,
      validator: (_) => selectedTemplateId == null ? "Required" : null,
      onTap: () {
        _showTemplateSearchDialog(_templateModel!.data);
      },
      decoration: InputDecoration(
        hintText: "Select Template",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        suffixIcon: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  void _showTemplateSearchDialog(List<TemplateData> templates) {
    FocusNode searchFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<TemplateData> filteredList = List.from(templates);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusScope.of(context).requestFocus(searchFocusNode);
            });

            return AlertDialog(
              scrollable: true,
              title: const Text("Select Template"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      focusNode: searchFocusNode,
                      autofocus: true,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = templates
                              .where((t) => t.templateName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search template...",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No templates found"))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final template = filteredList[index];
                                return InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    setState(() {
                                      selectedTemplateId = template.id;
                                      templateCtrl.text = template.templateName;
                                    });
                                    await _loadTemplateDetails(template.id);
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            template.templateName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (selectedTemplateId == template.id)
                                          const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                      ],
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

  Widget _productHeader() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            "Sl*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "Item*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            selectedRateType == "Fixed Rate" ? "Quantity*" : "Sq/ft*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: Text(
            selectedRateType == "Fixed Rate" ? "Unit Price*" : "Price/sqft*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            "Unit*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            "Total*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "GST*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "Sub Total*",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            "Action",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _productRow(int index, ProductRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text("${index + 1}", style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: row.materialCtrl,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select Item",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              validator: (_) => row.materialData == null ? "Required" : null,
              onTap: () {
                _showMaterialSearchDialog(materials, row);
              },
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.remove, size: 14),
                    onPressed: () {
                      double currentValue =
                          double.tryParse(row.quantityController.text) ?? 1.0;
                      if (currentValue > 1) {
                        row.quantityController.text =
                            (currentValue - 1).toStringAsFixed(0);
                        setState(() {});
                      } else if (currentValue > 0.1) {
                        row.quantityController.text =
                            (currentValue - 0.1).toStringAsFixed(1);
                        setState(() {});
                      }
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: row.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      counterText: '',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: () {
                      double currentValue =
                          double.tryParse(row.quantityController.text) ?? 1.0;
                      row.quantityController.text =
                          (currentValue + 1).toStringAsFixed(0);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              row.materialData?.unitName ?? 'Unit',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "₹${_calculateTotal(index).toStringAsFixed(2)}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.teal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.gstController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                isDense: true,
                suffixText: '%',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "₹${_calculateSubTotal(index).toStringAsFixed(2)}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.redAccent,
              onPressed: () => _removeProductRow(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {Color color = Colors.black87}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }

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
                      // final result = await _showQuickAddCustomerDialog(context);
                      // if (result != null && result) {
                      //   await _refreshAfterCustomerAdded();
                      // }
                      final result = await _showQuickAddCustomerDialog(context);
                      if (result != null && result) {
                        Navigator.pop(context);
                        await _refreshAfterCustomerAdded();
                      } else {
                        shouldAutoFocus = true;
                        if (mounted) {
                          _showCustomerSearchDialog(_customerModel?.data ?? []);
                        }
                      }
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
                      autofocus: true,
                      onChanged: (value) {
                         shouldAutoFocus = false;
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
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
                                    _selectCustomer(cust);
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

  void _selectCustomer(CustomerDetails cust) {
    setState(() {
      selectedCustomerId = cust.id;
      customerNameCtrl.text = cust.name;

      selectedWorkOrder = null;
      workOrders.clear();
      addressController.clear();
      districtController.clear();
      stateController.clear();
      nationalityController.clear();
      selectedStateId = null;
      selectedDistrictId = null;
      selectedStateName = null;
      selectedDistrictName = null;
      districtList.clear();
    });

    _loadWorkOrderId(cust.id);
    _loadCustomerDetails(cust.id);
  }

  Future<void> _refreshAfterCustomerAdded() async {
    setState(() {
      _isRefreshingCustomers = true;
    });

    try {
      await _loadCustomers(showLoading: false);
      if (mounted) {
        Navigator.pop(context);
        Common.toastMessaage('Customer added successfully', Colors.green);
        _showCustomerSearchDialog(_customerModel?.data ?? []);
      }
    } catch (e) {
      log("Error refreshing customers: $e");
      Common.toastMessaage('Failed to refresh customers', Colors.red);
    } finally {
      setState(() {
        _isRefreshingCustomers = false;
      });
    }
  }

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

  void _showMaterialSearchDialog(List<MaterialData> materials, ProductRow row) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<MaterialData> filteredList = List.from(materials);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text("Select Material"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = materials
                              .where((m) => (m.materialName ?? '')
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search material",
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
                          ? const Center(child: Text("No materials found"))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final material = filteredList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      row.materialData = material;
                                      row.materialCtrl.text =
                                          material.materialName ?? '';
                                      row.rateController.text =
                                          material.unitPrice ?? '0.00';
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      material.materialName ?? 'Unknown',
                                      style: const TextStyle(fontSize: 14),
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

  Widget _textField({
    required String label,
    String? hint,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint ?? '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePickerField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
            }
          },
        ),
      ],
    );
  }
}

class ProductRow {
  MaterialData? materialData;
  TextEditingController quantityController;
  TextEditingController rateController;
  TextEditingController gstController;
  TextEditingController materialCtrl;
  String rateType;

  ProductRow({
    required this.materialData,
    required this.quantityController,
    required this.rateController,
    required this.gstController,
    required this.rateType,
    required this.materialCtrl,
  });
}
