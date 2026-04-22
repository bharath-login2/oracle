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
import 'package:login2/models/lead_management/requestCreateResponseModel.dart';
import 'package:login2/models/lead_management/workOrderIdModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/quick_add_customer_dialog.dart';

class AddQuotationPage extends StatefulWidget {
  final String? requestId;
  String? custId;
  AddQuotationPage({Key? key, this.requestId, this.custId}) : super(key: key);
  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomer;
  String? selectedWorkOrder;
  String? selectedTemplate;
  bool isLoadingRequestData = false;
  RequestResponseModel? _requestResponse;
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
  bool includeProductImages = false;
  bool includeGst = false;
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
  bool _isDisposed = false;
  @override
  void initState() {
    if (widget.custId != null && widget.custId!.isNotEmpty) {
      selectedCustomerId = widget.custId;
    }
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    customerNameCtrl.dispose();
    templateCtrl.dispose();
    materialCtrl.dispose();
    enquiryDateController.dispose();
    addressController.dispose();
    districtController.dispose();
    stateController.dispose();
    nationalityController.dispose();
    for (var row in productRows) {
      row.quantityController.dispose();
      row.rateController.dispose();
      row.gstController.dispose();
      row.materialCtrl.dispose();
    }

    super.dispose();
  }

  // Future<void> _initializeData() async {
  //   try {
  //     await _loadToken();
  //     await _getStates();
  //     await Future.wait([
  //       _loadCustomers(),
  //       _loadMaterials(),
  //       _loadTemplates(),
  //     ]);

  //     if (widget.requestId != null &&
  //         widget.requestId!.isNotEmpty &&
  //         !_isDisposed) {
  //       await _fetchRequestData(widget.requestId!);
  //     }
  //   } catch (e) {
  //     print('🔥 Error initializing data: $e');
  //   }
  // }
  Future<void> _initializeData() async {
    try {
      await _loadToken();
      await _getStates();
      if (widget.custId != null && widget.custId!.isNotEmpty) {
        await _loadCustomers();
        if (_customerModel != null && _customerModel!.data.isNotEmpty) {
          final customer = _customerModel!.data.firstWhere(
            (c) => c.id == widget.custId,
            orElse: () => CustomerDetails(
                id: '', name: '', address: '', contactNo: '', emailId: ''),
          );
          if (customer.id.isNotEmpty) {
            _selectCustomer(customer);
          }
        }
      }
      await Future.wait([
        if (widget.custId == null) _loadCustomers(),
        _loadMaterials(),
        _loadTemplates(),
      ]);
      if (widget.requestId != null &&
          widget.requestId!.isNotEmpty &&
          !_isDisposed) {
        await _fetchRequestData(widget.requestId!);
      }
    } catch (e) {
      print('🔥 Error initializing data: $e');
    }
  }

  Future<void> _fetchRequestData(String requestId) async {
    if (_isDisposed) return;

    try {
      if (!_isDisposed) {
        setState(() => isLoadingRequestData = true);
      }

      final result = await HttpService.createRequestDetails(requestId);

      if (result != null && result.data != null) {
        _requestResponse = result;

        // Populate data without using context
        await _populateCustomerDetails(result.data!.customerData);
        await _populateProductDetails(result.data!.productDetails);

        if (!_isDisposed) {
          setState(() {});
        }
        print('✅ Request data loaded successfully');
      } else {
        print('⚠️ Failed to load request data');
        // Use a safer way to show message
        _showSafeToast('Failed to load request details', Colors.orange);
      }
    } catch (e) {
      print('🔥 Error fetching request data: $e');
      _showSafeToast('Error loading request data', Colors.red);
    } finally {
      if (!_isDisposed) {
        setState(() => isLoadingRequestData = false);
      }
    }
  }

  void _showSafeToast(String message, Color color) {
    print('Toast: $message');
  }

  _selectCustomerById(String customerId) async {
    try {
      // First, ensure customers are loaded
      if (_customerModel == null || _customerModel!.data.isEmpty) {
        await _loadCustomers();
      }

      if (_customerModel != null && _customerModel!.data.isNotEmpty) {
        final customer = _customerModel!.data.firstWhere(
          (c) => c.id == customerId,
          orElse: () => CustomerDetails(
              id: '', name: '', address: '', contactNo: '', emailId: ''),
        );

        if (customer.id.isNotEmpty) {
          if (!_isDisposed) {
            setState(() {
              selectedCustomerId = customer.id;
              customerNameCtrl.text = customer.name;
            });
          }

          // Load work orders and customer details
          _loadWorkOrderId(customer.id);
          await _loadCustomerDetails(customer.id);

          print('✅ Customer ${customer.name} selected automatically');
        } else {
          print('⚠️ Customer with ID $customerId not found');
          _showSafeToast('Customer not found', Colors.orange);
        }
      }
    } catch (e) {
      print('🔥 Error selecting customer by ID: $e');
    }
  }

  Future<void> _populateProductDetails(
      List<ProductDetail>? productDetails) async {
    if (productDetails == null || productDetails.isEmpty) return;

    try {
      // Clear existing product rows
      productRows.clear();

      // Add new product rows based on the response
      for (var product in productDetails) {
        MaterialData? matchedMaterial;
        if (materials.isNotEmpty) {
          matchedMaterial = materials.firstWhere(
            (material) =>
                (material.materialName ?? '').toLowerCase() ==
                (product.productname ?? '').toLowerCase(),
            orElse: () => MaterialData(),
          );
        }

        final row = ProductRow(
          materialData: matchedMaterial,
          quantityController: TextEditingController(
            text: (product.quantity ?? 0).toString(),
          ),
          rateController: TextEditingController(
            text: (product.unitPrice ?? 0.0).toStringAsFixed(2),
          ),
          gstController: TextEditingController(
            text: (product.gst ?? 0.0).toStringAsFixed(0),
          ),
          materialCtrl: TextEditingController(
            text: product.productname ?? 'Select Item',
          ),
          rateType: selectedRateType,
        );

        productRows.add(row);
      }

      if (!_isDisposed) {
        setState(() {});
      }
      print('✅ Loaded ${productDetails.length} products');
    } catch (e) {
      print('🔥 Error populating product details: $e');
    }
  }

  Future<void> _populateCustomerDetails(CustomerData? customerData) async {
    if (customerData == null || _isDisposed) return;
    try {
      if (!_isDisposed) {
        setState(() {
          addressController.text = customerData.address ?? '';
        });
      }

      // Set customer name from customer ID if available
      if (customerData.customerName != null && customerData.customerName!.isNotEmpty) {
        final customer = _customerModel?.data.firstWhere(
          (c) => c.id == customerData.customerName,
          orElse: () => CustomerDetails(id: '', name: '', address: '', contactNo: '', emailId: ''),
        );
        if (customer != null && customer.id.isNotEmpty) {
          setState(() {
            selectedCustomerId = customer.id;
            customerNameCtrl.text = customer.name;
          });
        }
      }

      if (customerData.state != null &&
          customerData.state!.isNotEmpty &&
          customerData.state != "0") {
        if (stateList.isEmpty) {
          await _getStates();
        }

        if (stateList.isNotEmpty && !_isDisposed) {
          final matchedState = stateList.firstWhere(
            (state) => state.id == customerData.state,
            orElse: () => StateList(id: '', name: ''),
          );
          if (matchedState.id.isNotEmpty) {
            if (!_isDisposed) {
              setState(() {
                selectedStateId = matchedState.id;
                selectedStateName = matchedState.name;
                stateController.text = matchedState.name;
              });
            }
            await _getDistricts(matchedState.id);
            if (customerData.district != null &&
                customerData.district!.isNotEmpty &&
                customerData.district != "0" &&
                !_isDisposed) {
              await Future.delayed(const Duration(milliseconds: 300));

              if (!_isDisposed && districtList.isNotEmpty) {
                final matchedDistrict = districtList.firstWhere(
                  (district) => district.id == customerData.district,
                  orElse: () => DistrictList(id: '', name: ''),
                );

                if (matchedDistrict.id.isNotEmpty) {
                  setState(() {
                    selectedDistrictId = matchedDistrict.id;
                    selectedDistrictName = matchedDistrict.name;
                    districtController.text = matchedDistrict.name;
                  });
                } else {
                  setState(() {
                    districtController.text = customerData.district!;
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('🔥 Error populating customer details: $e');
    }
  }

  // Future<void> _populateCustomerDetails(CustomerData? customerData) async {
  //   if (customerData == null || _isDisposed) return;
  //   try {
  //     if (!_isDisposed) {
  //       setState(() {
  //         addressController.text = customerData.address ?? '';
  //       });
  //     }
  //     if (customerData.customerName != null &&
  //         customerData.customerName!.isNotEmpty) {
  //       bool shouldAutoSelect = widget.custId != null &&
  //           widget.custId!.isNotEmpty &&
  //           customerData.customerName == widget.custId;
  //       if (_customerModel == null || _customerModel!.data.isEmpty) {
  //         await _loadCustomers();
  //       }
  //       if (_customerModel != null && _customerModel!.data.isNotEmpty) {
  //         final matchedCustomer = _customerModel!.data.firstWhere(
  //           (customer) => customer.id == customerData.customerName,
  //           orElse: () => CustomerDetails(
  //               id: '', name: '', address: '', contactNo: '', emailId: ''),
  //         );
  //         if (matchedCustomer.id.isNotEmpty) {
  //           if (!_isDisposed) {
  //             setState(() {
  //               selectedCustomerId = matchedCustomer.id;
  //               customerNameCtrl.text = matchedCustomer.name;
  //             });
  //           }
  //           _loadWorkOrderId(matchedCustomer.id);
  //           await _loadCustomerDetails(matchedCustomer.id);
  //         } else {
  //           print(
  //               '⚠️ Customer ID ${customerData.customerName} not found in customer list');

  //           if (shouldAutoSelect && widget.custId != null) {
  //             await _selectCustomerById(widget.custId!);
  //           } else {
  //             if (!_isDisposed) {
  //               setState(() {
  //                 selectedCustomerId = null;
  //                 customerNameCtrl.text = "";
  //                 selectedWorkOrder = null;
  //                 workOrders = ["No Work Order ID"];
  //               });
  //             }
  //           }
  //         }
  //       }
  //     }

  //     if (customerData.state != null && customerData.state!.isNotEmpty) {
  //       if (stateList.isEmpty) {
  //         await _getStates();
  //       }

  //       if (stateList.isNotEmpty && !_isDisposed) {
  //         final matchedState = stateList.firstWhere(
  //           (state) => state.id == customerData.state,
  //           orElse: () => StateList(id: '', name: ''),
  //         );
  //         if (matchedState.id.isNotEmpty) {
  //           if (!_isDisposed) {
  //             setState(() {
  //               selectedStateId = matchedState.id;
  //               selectedStateName = matchedState.name;
  //               stateController.text = matchedState.name;
  //             });
  //           }
  //           await _getDistricts(matchedState.id);
  //           if (customerData.district != null &&
  //               customerData.district!.isNotEmpty &&
  //               !_isDisposed) {
  //             await Future.delayed(const Duration(milliseconds: 300));
  //             if (!_isDisposed && districtList.isNotEmpty) {
  //               final matchedDistrict = districtList.firstWhere(
  //                 (district) => district.id == customerData.district,
  //                 orElse: () => DistrictList(id: '', name: ''),
  //               );
  //               if (matchedDistrict.id.isNotEmpty) {
  //                 setState(() {
  //                   selectedDistrictId = matchedDistrict.id;
  //                   selectedDistrictName = matchedDistrict.name;
  //                   districtController.text = matchedDistrict.name;
  //                 });
  //               } else {
  //                 setState(() {
  //                   districtController.text = customerData.district!;
  //                 });
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('🔥 Error populating customer details: $e');
  //   }
  // }

  Future<void> _loadMaterials() async {
    if (_isDisposed) return;
    setState(() => isLoadingMaterials = true);
    final httpService = HttpService();
    final materialList = await HttpService.getMaterials();
    if (!_isDisposed) {
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
  }

  Future<void> _loadCustomers({bool showLoading = true}) async {
    if (_isDisposed) return;

    if (showLoading) {
      setState(() => isLoadingCustomers = true);
    }

    final customerList = await HttpService.getCustomerList();
    if (!_isDisposed) {
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
  }

  Future<void> _loadToken() async {
    token = await Common.getSharedPref("token");
  }

  Future<void> _getStates() async {
    if (_isDisposed) return;

    setState(() => isLoadingState = true);
    final response = await HttpService.getState();
    if (!_isDisposed) {
      if (response != null && response.status == true) {
        setState(() {
          stateList = response.data;
          isLoadingState = false;
        });
      } else {
        setState(() => isLoadingState = false);
      }
    }
  }

  Future<void> _getDistricts(String stateId) async {
    if (_isDisposed) return;

    setState(() {
      isLoadingDistrict = true;
    });

    final response = await HttpService.getDistrict(stateId);
    if (!_isDisposed) {
      if (response != null && response.status == true) {
        setState(() {
          districtList = response.data;
          isLoadingDistrict = false;
        });
      } else {
        setState(() => isLoadingDistrict = false);
      }
    }
  }

  Map<String, double> _calculateGrandTotals() {
    double totalGstAmount = 0;
    double totalSubTotal = 0;
    for (int i = 0; i < productRows.length; i++) {
      final total = _calculateTotal(i);
      double gstPercentage =
          double.tryParse(productRows[i].gstController.text) ?? 0.0;
      double gstAmount = total * (gstPercentage / 100);
      totalGstAmount += gstAmount;
      totalSubTotal += _calculateSubTotal(i);
    }
    return {
      'gstAmount': totalGstAmount,
      'subTotal': totalSubTotal,
    };
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
        final total = double.tryParse(row.quantityController.text) ??
            0.0 * (double.tryParse(row.rateController.text) ?? 0.0);
        final gstPercentage = double.tryParse(row.gstController.text) ?? 0.0;
        final gstAmount = total * (gstPercentage / 100);
        return {
          "material_id": row.materialData?.materialId ?? '',
          "material_name": row.materialData?.materialName ?? '',
          "quantity": row.quantityController.text,
          "rate": row.rateController.text,
          "gst": row.gstController.text,
          "gst_amount": gstAmount.toStringAsFixed(2),
          "total": _calculateSubTotal(
            productRows.indexOf(row),
          ).toStringAsFixed(2),
          "unit": row.materialData?.unitName ?? '',
        };
      }).toList();
      final formData = FormData.fromMap({
        "customer_id": selectedCustomerId ?? '',
        "work_order_id": selectedWorkOrder ?? '',
        "quotation_request_id": widget.requestId ?? '',
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
        "total_gst_amount":
            _calculateGrandTotals()['gstAmount']?.toStringAsFixed(2) ?? '0.00',
        "grand_total":
            _calculateGrandTotals()['subTotal']?.toStringAsFixed(2) ?? '0.00',
        "include_product_images": includeProductImages ? "1" : "0",
        "include_gst": includeGst ? "1" : "0",
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

  // Future<void> _submitQuotation() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   try {
  //     final httpService = HttpService();
  //     final templateFields = _templateDetailsModel?.data?.fields
  //             ?.map(
  //               (field) => ({
  //                 "field_name": field.fieldName ?? '',
  //                 "field_value": field.fieldData ?? '',
  //               }),
  //             )
  //             .toList() ??
  //         [];
  //     final productList = productRows.map((row) {
  //       return {
  //         "material_id": row.materialData?.materialId ?? '',
  //         "material_name": row.materialData?.materialName ?? '',
  //         "quantity": row.quantityController.text,
  //         "rate": row.rateController.text,
  //         "gst": row.gstController.text,
  //         "gst_amount": row.gstController.text,
  //         "total": _calculateSubTotal(
  //           productRows.indexOf(row),
  //         ).toStringAsFixed(2),
  //         "unit": row.materialData?.unitName ?? '',
  //       };
  //     }).toList();
  //     final formData = FormData.fromMap({
  //       "customer_id": selectedCustomerId ?? '',
  //       "work_order_id": selectedWorkOrder ?? '',
  //       "quotation_request_id": widget.requestId ?? '',
  //       "quotation_id": quotationId,
  //       "enquiry_date": enquiryDateController.text,
  //       "rate_type": selectedRateType,
  //       "address": addressController.text,
  //       "district": selectedDistrictId ?? '',
  //       "district_name": selectedDistrictName ?? districtController.text,
  //       "state": selectedStateId ?? '',
  //       "state_name": selectedStateName ?? stateController.text,
  //       "nationality": nationalityController.text,
  //       "template_id": selectedTemplateId ?? '',
  //       "template_fields": jsonEncode(templateFields),
  //       "products": jsonEncode(productList),
  //     });

  //     final response = await httpService.submitQuotation(formData);

  //     if (response != null && response["status"] == "success") {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text(
  //             "Quotation submitted successfully!",
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           margin: const EdgeInsets.all(16),
  //         ),
  //       );
  //       Navigator.pop(context);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             response?["message"] ?? "Submission failed",
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           margin: const EdgeInsets.all(16),
  //         ),
  //       );
  //     }
  //   } catch (e, stack) {
  //     log("Quotation submission error: $e");
  //     log(stack.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text(
  //           "An error occurred while submitting",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         margin: const EdgeInsets.all(16),
  //       ),
  //     );
  //   }
  // }

  Future<void> _loadTemplates() async {
    if (_isDisposed) return;

    setState(() => isLoadingTemplates = true);

    final httpService = HttpService();
    final templateList = await httpService.getTemplateList();

    if (!_isDisposed) {
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
  }

  Future<void> _loadTemplateDetails(String templateId) async {
    if (_isDisposed) return;

    setState(() => isLoadingTemplates = true);
    final httpService = HttpService();
    final templateDetails = await httpService.getTemplateDetails(templateId);
    if (!_isDisposed) {
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
  }

  // Future<void> _loadCustomerDetails(String customerId) async {
  //   if (customerId.isEmpty || _isDisposed) return;

  //   try {
  //     final httpService = HttpService();
  //     final customerDetails = await httpService.getCustomerDetails(customerId);

  //     if (!_isDisposed) {
  //       if (customerDetails != null &&
  //           customerDetails.data.isNotEmpty &&
  //           customerDetails.status == "success") {
  //         final customerData = customerDetails.data.first;

  //         // The API returns IDs, not names
  //         final stateIdFromApi = customerData.state;
  //         final districtIdFromApi = customerData.district;

  //         // Find state name from stateList using the ID
  //         String? stateName;
  //         if (stateIdFromApi.isNotEmpty && stateList.isNotEmpty) {
  //           final matchedState = stateList.firstWhere(
  //             (state) => state.id == stateIdFromApi,
  //             orElse: () => StateList(id: '', name: ''),
  //           );
  //           stateName = matchedState.name;
  //         }

  //         // If state is found, load districts for that state
  //         if (stateIdFromApi.isNotEmpty && stateIdFromApi != selectedStateId) {
  //           await _getDistricts(stateIdFromApi);
  //         }

  //         // Find district name from districtList using the ID
  //         String? districtName;
  //         if (districtIdFromApi.isNotEmpty && districtList.isNotEmpty) {
  //           final matchedDistrict = districtList.firstWhere(
  //             (district) => district.id == districtIdFromApi,
  //             orElse: () => DistrictList(id: '', name: ''),
  //           );
  //           districtName = matchedDistrict.name;
  //         }

  //         setState(() {
  //           // Only update address if it's empty (don't overwrite request data)
  //           if (addressController.text.isEmpty) {
  //             addressController.text = customerData.address;
  //           }

  //           // Update other fields
  //           nationalityController.text = customerData.nationality;

  //           // Set state dropdown only if not already set from request
  //           if (stateIdFromApi.isNotEmpty && selectedStateId == null) {
  //             selectedStateId = stateIdFromApi;
  //             selectedStateName = stateName ?? stateIdFromApi;
  //             stateController.text = stateName ?? stateIdFromApi;
  //           }

  //           // Set district dropdown only if not already set from request
  //           if (districtIdFromApi.isNotEmpty && selectedDistrictId == null) {
  //             selectedDistrictId = districtIdFromApi;
  //             selectedDistrictName = districtName ?? districtIdFromApi;
  //             districtController.text = districtName ?? districtIdFromApi;
  //           }
  //         });

  //         log("Customer Details: State ID: $stateIdFromApi, District ID: $districtIdFromApi");
  //         log("State Name: $stateName, District Name: $districtName");
  //       }
  //     }
  //   } catch (e, stack) {
  //     log("Customer details loading error: $e");
  //     log(stack.toString());
  //   }
  // }

  Future<void> _loadCustomerDetails(String customerId) async {
    if (customerId.isEmpty || _isDisposed) return;

    try {
      final httpService = HttpService();
      final customerDetails = await httpService.getCustomerDetails(customerId);

      if (!_isDisposed) {
        if (customerDetails != null &&
            customerDetails.data.isNotEmpty &&
            customerDetails.status == "success") {
          final customerData = customerDetails.data.first;

          final stateIdFromApi = customerData.state;
          final districtIdFromApi = customerData.district;

          // FIX: Check for "0" or empty values
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
              if (addressController.text.isEmpty) {
                addressController.text = customerData.address;
              }

              nationalityController.text = customerData.nationality;

              // FIX: Only set if not "0"
              if (selectedStateId == null) {
                selectedStateId = stateIdFromApi;
                selectedStateName = stateName ?? stateIdFromApi;
                stateController.text = stateName ?? stateIdFromApi;
              }
            });
          }

          // FIX: Check for "0" or empty values for district
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
              // FIX: Only set if not "0"
              if (selectedDistrictId == null) {
                selectedDistrictId = districtIdFromApi;
                selectedDistrictName = districtName ?? districtIdFromApi;
                districtController.text = districtName ?? districtIdFromApi;
              }
            });
          }

          log("Customer Details: State ID: $stateIdFromApi, District ID: $districtIdFromApi");
        }
      }
    } catch (e, stack) {
      log("Customer details loading error: $e");
    }
  }

  Future<void> _loadWorkOrderId(String customerId) async {
    if (_isDisposed) return;

    setState(() => isLoadingTemplates = true);

    final httpService = HttpService();
    final workOrderResponse = await httpService.getWorkorderId(customerId);

    if (!_isDisposed) {
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
    if (isLoadingRequestData) {
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
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading request details...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Quotation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        //   centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        actions: [
          if (widget.requestId != null && !isLoadingRequestData)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _fetchRequestData(widget.requestId!),
              tooltip: 'Reload request data',
            ),
        ],
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
                    // Info banner for request-based quotation
                    if (widget.requestId != null && _requestResponse != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Quotation based on Request #${widget.requestId}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                            if (_requestResponse?.data?.productDetails != null)
                              Chip(
                                label: Text(
                                  '${_requestResponse!.data!.productDetails!.length} items',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue.shade100,
                              ),
                          ],
                        ),
                      ),

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
                        // Expanded(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       const Text(
                        //         "State ",
                        //         style: TextStyle(
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.black87,
                        //         ),
                        //       ),
                        //       const SizedBox(height: 6),
                        //       isLoadingState
                        //           ? const Center(
                        //               child: CircularProgressIndicator())
                        //           : DropdownButtonFormField<String>(
                        //               value: selectedStateId,
                        //               hint: const Text("Select State"),
                        //               decoration: InputDecoration(
                        //                 border: OutlineInputBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(12),
                        //                 ),
                        //                 contentPadding:
                        //                     const EdgeInsets.symmetric(
                        //                   horizontal: 12,
                        //                   vertical: 10,
                        //                 ),
                        //               ),
                        //               items: stateList.map((state) {
                        //                 return DropdownMenuItem<String>(
                        //                   value: state.id,
                        //                   child: Text(state.name),
                        //                   onTap: () {
                        //                     setState(() {
                        //                       selectedStateName = state.name;
                        //                       stateController.text = state.name;
                        //                     });
                        //                   },
                        //                 );
                        //               }).toList(),
                        //               onChanged: (value) {
                        //                 setState(() {
                        //                   selectedStateId = value;
                        //                   if (value != null) {
                        //                     final state = stateList.firstWhere(
                        //                       (s) => s.id == value,
                        //                       orElse: () =>
                        //                           StateList(id: '', name: ''),
                        //                     );
                        //                     if (state.id.isNotEmpty) {
                        //                       selectedStateName = state.name;
                        //                       stateController.text = state.name;
                        //                     }
                        //                   } else {
                        //                     selectedStateName = null;
                        //                     stateController.clear();
                        //                   }
                        //                   // Clear district when state changes
                        //                   selectedDistrictId = null;
                        //                   selectedDistrictName = null;
                        //                   districtController.clear();
                        //                   districtList.clear();
                        //                 });
                        //                 if (value != null) _getDistricts(value);
                        //               },
                        //             ),
                        //     ],
                        //   ),
                        // ),
                        // State Dropdown - Add this fix
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "State ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: stateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Select State",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: isLoadingState
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.arrow_drop_down),
                                ),
                                onTap: isLoadingState
                                    ? null
                                    : () => _showStateSelectionDialog(),
                                validator: (_) =>
                                    selectedStateId == null ? "Required" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Expanded(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       const Text(
                        //         "District ",
                        //         style: TextStyle(
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.black87,
                        //         ),
                        //       ),
                        //       const SizedBox(height: 6),
                        //       isLoadingDistrict
                        //           ? const Center(
                        //               child: CircularProgressIndicator())
                        //           : DropdownButtonFormField<String>(
                        //               value: selectedDistrictId,
                        //               hint: const Text("Select District"),
                        //               decoration: InputDecoration(
                        //                 border: OutlineInputBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(12),
                        //                 ),
                        //                 contentPadding:
                        //                     const EdgeInsets.symmetric(
                        //                   horizontal: 12,
                        //                   vertical: 10,
                        //                 ),
                        //               ),
                        //               items: districtList.map((district) {
                        //                 return DropdownMenuItem<String>(
                        //                   value: district.id,
                        //                   child: Text(district.name),
                        //                   onTap: () {
                        //                     setState(() {
                        //                       selectedDistrictName =
                        //                           district.name;
                        //                       districtController.text =
                        //                           district.name;
                        //                     });
                        //                   },
                        //                 );
                        //               }).toList(),
                        //               onChanged: (value) {
                        //                 setState(() {
                        //                   selectedDistrictId = value;
                        //                   if (value != null) {
                        //                     final district =
                        //                         districtList.firstWhere(
                        //                       (d) => d.id == value,
                        //                       orElse: () => DistrictList(
                        //                           id: '', name: ''),
                        //                     );
                        //                     if (district.id.isNotEmpty) {
                        //                       selectedDistrictName =
                        //                           district.name;
                        //                       districtController.text =
                        //                           district.name;
                        //                     }
                        //                   } else {
                        //                     selectedDistrictName = null;
                        //                     districtController.clear();
                        //                   }
                        //                 });
                        //               },
                        //             ),
                        //     ],
                        //   ),
                        // ),
                        // District Dropdown - Add this fix
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "District ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: districtController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Select District",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: isLoadingDistrict
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.arrow_drop_down),
                                ),
                                onTap: isLoadingDistrict
                                    ? null
                                    : () => _showDistrictSelectionDialog(),
                                validator: (_) => selectedDistrictId == null
                                    ? "Required"
                                    : null,
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: includeProductImages,
                              activeColor:
                                  const Color.fromARGB(255, 22, 145, 216),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) {
                                setState(() {
                                  includeProductImages = val ?? false;
                                });
                              },
                            ),
                            const Text("Include product Images",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: includeGst,
                              activeColor:
                                  const Color.fromARGB(255, 22, 145, 216),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) {
                                setState(() {
                                  includeGst = val ?? false;
                                });
                              },
                            ),
                            const Text("Include GST and GST Amount",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
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
            horizontal: 14,
            vertical: 16,
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
    showDialog(
      context: context,
      builder: (context) {
        return _TemplateSearchDialog(
          templates: templates,
          selectedTemplateId: selectedTemplateId,
          onTemplateSelected: (template) async {
            Navigator.pop(context);
            setState(() {
              selectedTemplateId = template.id;
              templateCtrl.text = template.templateName;
            });
            await _loadTemplateDetails(template.id);
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
        // Expanded(
        //   flex: 1,
        //   child: Text(
        //     "Unit*",
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Colors.teal.shade800,
        //     ),
        //   ),
        // ),
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
        if (includeGst) ...[
          Expanded(
            flex: 2,
            child: Text(
              "GST %*",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "GST Amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
        ],
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
    // Calculate GST Amount
    double calculateGstAmount() {
      final total = _calculateTotal(index);
      double gstPercentage = double.tryParse(row.gstController.text) ?? 0.0;
      return total * (gstPercentage / 100);
    }

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
          if (includeGst) ...[
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
                "₹${calculateGstAmount().toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
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
    showDialog(
      context: context,
      builder: (context) {
        return _CustomerSearchDialog(
          customers: customers,
          selectedCustomerId: selectedCustomerId,
          onCustomerSelected: (customer) {
            _selectCustomer(customer);
            Navigator.pop(context);
          },
          onAddCustomer: () async {
            final result = await _showQuickAddCustomerDialog(context);
            if (result != null && result) {
              Navigator.pop(context);
              await _refreshAfterCustomerAdded();
            }
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
      // Don't clear address, state, district if they were set from request
      if (_requestResponse == null) {
        addressController.clear();
        districtController.clear();
        stateController.clear();
        nationalityController.clear();
        selectedStateId = null;
        selectedDistrictId = null;
        selectedStateName = null;
        selectedDistrictName = null;
        districtList.clear();
      }
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
      if (!_isDisposed) {
        _showCustomerSearchDialog(_customerModel?.data ?? []);
      }
    } catch (e) {
      log("Error refreshing customers: $e");
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isRefreshingCustomers = false;
        });
      }
    }
  }

  void _showStateSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _GenericSearchDialog(
        title: "Select State",
        hintText: "Search state",
        items: stateList,
        onSelected: (state) {
          setState(() {
            selectedStateId = state.id;
            selectedStateName = state.name;
            stateController.text = state.name;

            // Clear district when state changes
            selectedDistrictId = null;
            selectedDistrictName = null;
            districtController.clear();
            districtList.clear();
          });
          _getDistricts(state.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDistrictSelectionDialog() {
    if (selectedStateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a state first")),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => _GenericSearchDialog(
        title: "Select District",
        hintText: "Search district",
        items: districtList,
        onSelected: (district) {
          setState(() {
            selectedDistrictId = district.id;
            selectedDistrictName = district.name;
            districtController.text = district.name;
          });
          Navigator.pop(context);
        },
      ),
    );
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
        return _MaterialSearchDialog(
          materials: materials,
          onMaterialSelected: (material) {
            setState(() {
              row.materialData = material;
              row.materialCtrl.text = material.materialName ?? '';
              row.rateController.text = material.unitPrice ?? '0.00';
            });
            Navigator.pop(context);
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

// Separate dialog widgets to avoid context issues
class _TemplateSearchDialog extends StatefulWidget {
  final List<TemplateData> templates;
  final String? selectedTemplateId;
  final Function(TemplateData) onTemplateSelected;

  const _TemplateSearchDialog({
    required this.templates,
    required this.selectedTemplateId,
    required this.onTemplateSelected,
  });

  @override
  __TemplateSearchDialogState createState() => __TemplateSearchDialogState();
}

class __TemplateSearchDialogState extends State<_TemplateSearchDialog> {
  late TextEditingController searchCtrl;
  late List<TemplateData> filteredList;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredList = List.from(widget.templates);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text("Select Templates"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        // Reduce height to account for keyboard
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  filteredList = widget.templates
                      .where((t) => t.templateName
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search template...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                      // Add bottom padding for keyboard
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final template = filteredList[index];
                        return InkWell(
                          onTap: () {
                            widget.onTemplateSelected(template);
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
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                if (widget.selectedTemplateId == template.id)
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
  }
}

class _CustomerSearchDialog extends StatefulWidget {
  final List<CustomerDetails> customers;
  final String? selectedCustomerId;
  final Function(CustomerDetails) onCustomerSelected;
  final Function() onAddCustomer;

  const _CustomerSearchDialog({
    required this.customers,
    required this.selectedCustomerId,
    required this.onCustomerSelected,
    required this.onAddCustomer,
  });

  @override
  __CustomerSearchDialogState createState() => __CustomerSearchDialogState();
}

class __CustomerSearchDialogState extends State<_CustomerSearchDialog> {
  late TextEditingController searchCtrl;
  late List<CustomerDetails> filteredList;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredList = List.from(widget.customers);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Select Customer"),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue, size: 24),
            onPressed: widget.onAddCustomer,
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
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  filteredList = widget.customers
                      .where((c) =>
                          c.name.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search customer",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                            widget.onCustomerSelected(cust);
                          },
                          child: Container(
                            height: 45,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
  }
}

class _MaterialSearchDialog extends StatefulWidget {
  final List<MaterialData> materials;
  final Function(MaterialData) onMaterialSelected;

  const _MaterialSearchDialog({
    required this.materials,
    required this.onMaterialSelected,
  });

  @override
  __MaterialSearchDialogState createState() => __MaterialSearchDialogState();
}

class __MaterialSearchDialogState extends State<_MaterialSearchDialog> {
  late TextEditingController searchCtrl;
  late List<MaterialData> filteredList;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredList = List.from(widget.materials);
    // _initializeData();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  filteredList = widget.materials
                      .where((m) => (m.materialName ?? '')
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search material",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                            widget.onMaterialSelected(material);
                          },
                          child: Container(
                            height: 45,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
  }
}

class _GenericSearchDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final List<dynamic> items;
  final Function(dynamic) onSelected;

  const _GenericSearchDialog({
    required this.title,
    required this.hintText,
    required this.items,
    required this.onSelected,
  });

  @override
  __GenericSearchDialogState createState() => __GenericSearchDialogState();
}

class __GenericSearchDialogState extends State<_GenericSearchDialog> {
  late TextEditingController searchCtrl;
  late List<dynamic> filteredList;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredList = List.from(widget.items);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  filteredList = widget.items.where((item) {
                    final name = item.name ?? "";
                    return name.toLowerCase().contains(value.toLowerCase());
                  }).toList();
                });
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("No items found"))
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return ListTile(
                          title: Text(item.name ?? ""),
                          onTap: () => widget.onSelected(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
