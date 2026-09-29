import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/leadSubTypeModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/widgets/AddLeadSourceDialog.dart';
import 'package:login2/widgets/addLeadCateoryPopup.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/getLeadSourceModel.dart';
import '../../models/userPermissionModel.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/productDescriptionModel.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadExtraSettings.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/staff_list_model.dart';
import 'package:login2/models/expense/staffListModel.dart' as expense;
import 'package:login2/widgets/estimation_pricing_card.dart';
import 'dart:developer';

class AddLeadsNew extends StatefulWidget {
  final String? token;
  final String? page;
  final String? leadMasterId;
  final String? clientName;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? fromDate;
  final String? toDate;
  final bool? editLead;
  final bool? deleteLead;
  final bool? cloudCall;
  final String? countryCode;
  final String? address;
  final String? email;
  final String? cost;
  final String? leadCategoryId;
  final String? leadSubCategoryId;
  final String? priorityId;
  final String? leadSourceId;
  final String? remarks;
  final String? pinCode;
  final String? stateId;
  final String? districtId;
  final String? assignedUserId;
  final String? leadCategory;
  final String? leadSubCategory;
  final String? leadSource;
  final String? priority;
  final String? stateName;
  final String? districtName;
  final String? products;
  final String? whatsappCode;
  final String? assignStaff;
  final String? postOffice;

  AddLeadsNew(this.token,
      {super.key,
      this.page,
      this.leadMasterId,
      this.clientName,
      this.phoneNumber,
      this.whatsappNumber,
      this.fromDate,
      this.toDate,
      this.editLead,
      this.deleteLead,
      this.cloudCall,
      this.countryCode,
      this.address,
      this.email,
      this.cost,
      this.leadCategoryId,
      this.leadSubCategoryId,
      this.priorityId,
      this.leadSourceId,
      this.remarks,
      this.pinCode,
      this.stateId,
      this.districtId,
      this.assignedUserId,
      this.leadCategory,
      this.leadSubCategory,
      this.leadSource,
      this.priority,
      this.stateName,
      this.districtName,
      this.products,
      this.whatsappCode,
      this.assignStaff,
      this.postOffice});

  @override
  State<AddLeadsNew> createState() => _AddLeadsNewState();
}

class _AddLeadsNewState extends State<AddLeadsNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  final ScrollController _scrollController = ScrollController();
  LeadDeatailsModel? estimationDetails;

  // Form Fields
  String leadType = 'Lead Category', leadTypeId = '';
  String leadSubType = 'Lead Sub Category', leadSubTypeId = '';
  String assignStaff = 'Assign Staff', assignStaffId = '';
  String callResult = 'New', callResultId = '1';
  String leadSource = 'Direct Entry', leadSourceId = "1";
  String priority = 'Normal', priorityId = '2';
  UserPermissionModel? userPermissions;

  final TextEditingController leadTypeCtrl =
      TextEditingController(text: 'Lead Category');
  final TextEditingController leadSubTypeCtrl =
      TextEditingController(text: 'Lead Sub Category');
  final TextEditingController assignStaffCtrl =
      TextEditingController(text: 'Assign Staff');
  final TextEditingController leadSourceCtrl =
      TextEditingController(text: 'Direct Entry');
  final TextEditingController priorityCtrl =
      TextEditingController(text: 'Normal');
  final TextEditingController callResultCtrl =
      TextEditingController(text: 'New');
  String callResponse = 'Call Response', callResponseId = '';

  final TextEditingController clientNameCtrl = TextEditingController();
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController costCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController nextFollowupCtrl = TextEditingController();
  final TextEditingController timeBeforeCtrl =
      TextEditingController(text: '10');
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController callResponseCtrl = TextEditingController();
  final TextEditingController whatsappNoCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  // Estimation & Pricing Controllers & Variables
  final TextEditingController _pQuotationTitle = TextEditingController();
  final TextEditingController _pQuotation = TextEditingController();
  final TextEditingController _pClientName = TextEditingController();
  final TextEditingController _pPhone = TextEditingController();
  final TextEditingController _pLocation = TextEditingController();
  final TextEditingController _pElevatorType = TextEditingController();
  final TextEditingController _pTypeOfOpening = TextEditingController();
  final TextEditingController _pCapacity = TextEditingController();
  final TextEditingController _pPassengerCapacity = TextEditingController();
  final TextEditingController _pShaftWidth = TextEditingController();
  final TextEditingController _pShaftDepth = TextEditingController();
  final TextEditingController _pPitDepth = TextEditingController();
  final TextEditingController _pTravelHeight = TextEditingController();
  final TextEditingController _pOverheadHeight = TextEditingController();
  final TextEditingController _pWarranty = TextEditingController();
  final TextEditingController _pAmc = TextEditingController();

  final TextEditingController _pFactoryPrice = TextEditingController();
  final TextEditingController _pTransportation = TextEditingController();
  final TextEditingController _pInstallation = TextEditingController();
  final TextEditingController _pTesting = TextEditingController();
  final TextEditingController _pConsumables = TextEditingController();
  final TextEditingController _pAdditionalFactory = TextEditingController();
  final TextEditingController _pAdditional = TextEditingController();
  final TextEditingController _pAmcAmount = TextEditingController();
  final TextEditingController _pQuantity = TextEditingController(text: '1');
  final TextEditingController _pUnitPrice = TextEditingController();
  final TextEditingController _pCompanyProfit = TextEditingController();
  final TextEditingController _pCompanyProfitAmount = TextEditingController();
  final TextEditingController _pSalesCommission = TextEditingController();
  final TextEditingController _pSalesCommissionAmount = TextEditingController();
  final TextEditingController _pSubTotal = TextEditingController();
  final TextEditingController _pTaxPercentage = TextEditingController();
  final TextEditingController _pTaxAmount = TextEditingController();
  final TextEditingController _pTotalSalePrice = TextEditingController();
  final TextEditingController _quotationTitleCtrl =
      TextEditingController(text: "Quotation Request");

  final TextEditingController _quotationMessageCtrl = TextEditingController(
    text: "Kindly prepare and send the quotation for this lead.",
  );
  // Dropdown selections for estimation specs
  String? _pLiftTypeId;
  String? _pOpeningId;
  String? _pDoorOpeningId;
  String? _pCabinSideWallId;
  String? _pLandingDoorId;
  String? _pCopId;
  String? _pLopId;
  String? _pTaxType;

  String? _quotationType = "General";
  String? _quotationAssignedTo;
  bool _sendQuotation = false;

  List<expense.Staff> quotationStaffList = [];
  bool isQuotationStaffLoading = false;
  // Additional Fields
  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];

  // Data Models
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  LeadProductSectionModel? productSectionModel;
  GetLeadSourceModel? leadSourceModel;

  List<LeadProduct> _selectedProducts = [];

  bool isLoading = true,
      isDistrictLoading = false,
      isPinLoading = false,
      isLoadingSettings = false,
      checked = false;
  LeadSettings? leadSettings;
  String? _expandedProductId;
  final Map<String, String> _productDescriptions = {};
  final Map<String, bool> _descriptionLoading = {};

  Future<void> _loadQuotationStaffs() async {
    setState(() {
      isQuotationStaffLoading = true;
    });

    try {
      final response = await HttpService.getStaffs();

      if (response != null && response.status) {
        if (mounted) {
          setState(() {
            quotationStaffList = response.data;
            isQuotationStaffLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            quotationStaffList = [];
            isQuotationStaffLoading = false;
          });
        }
      }
    } catch (e) {
      log("Error loading quotation staff: $e");

      if (mounted) {
        setState(() {
          quotationStaffList = [];
          isQuotationStaffLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProductDescription(String productId) async {
    if (_productDescriptions.containsKey(productId)) return;
    setState(() => _descriptionLoading[productId] = true);
    try {
      final response = await HttpService.productDescription(productId);
      if (mounted) {
        setState(() {
          _descriptionLoading[productId] = false;
          if (response != null && response.status == true) {
            _productDescriptions[productId] = response.data;
          } else {
            _productDescriptions[productId] = "";
          }
        });
      }
    } catch (e) {
      log("Error fetching product description: $e");
      if (mounted) {
        setState(() {
          _descriptionLoading[productId] = false;
          _productDescriptions[productId] = "Failed to load description.";
        });
      }
    }
  }

  Future<void> _fetchLeadExtraSettings(String callResultId) async {
    setState(() => isLoadingSettings = true);
    try {
      final response = await HttpService.leadExtraSettings(callResultId);
      if (mounted) {
        setState(() {
          isLoadingSettings = false;
          if (response != null && response.status == true) {
            leadSettings = response.data.settings;
          } else {
            leadSettings = null;
          }
        });
      }
    } catch (e) {
      log("Error fetching lead extra settings: $e");
      if (mounted) setState(() => isLoadingSettings = false);
    }
  }

  String code = '91', whatsappCode = '91', roleId = '', multiBranch = '';
  String? branch;
  String? contactPermission, createLeadCategory, addLeadSource;
  String? StateId, DistrictId;

  @override
  void initState() {
    super.initState();
    clientNameCtrl.text = widget.clientName ?? "";
    contactNoCtrl.text = _trimPlus91(widget.phoneNumber ?? "");
    whatsappNoCtrl.text = _trimPlus91(widget.whatsappNumber ?? "");
    addressCtrl.text = widget.address ?? "";
    emailCtrl.text = widget.email ?? "";

    // Pre-fill fields from widget parameters
    costCtrl.text = widget.cost ?? "";
    remarkCtrl.text = widget.remarks ?? "";
    pinCodeCtrl.text = widget.pinCode ?? "";
    stateCtrl.text = widget.stateName ?? "";
    districtCtrl.text = widget.districtName ?? "";

    if (widget.leadCategory != null) {
      leadType = widget.leadCategory!;
      leadTypeCtrl.text = widget.leadCategory!;
    }
    if (widget.leadCategoryId != null) {
      leadTypeId = widget.leadCategoryId!;
    }

    if (widget.leadSubCategory != null) {
      leadSubType = widget.leadSubCategory!;
      leadSubTypeCtrl.text = widget.leadSubCategory!;
    }
    if (widget.leadSubCategoryId != null) {
      leadSubTypeId = widget.leadSubCategoryId!;
    }

    if (widget.leadSource != null) {
      leadSource = widget.leadSource!;
      leadSourceCtrl.text = widget.leadSource!;
    }
    if (widget.leadSourceId != null) {
      leadSourceId = widget.leadSourceId!;
    }

    if (widget.priority != null) {
      priority = widget.priority!;
      priorityCtrl.text = widget.priority!;
    }
    if (widget.priorityId != null) {
      priorityId = widget.priorityId!;
    }

    if (widget.assignStaff != null) {
      assignStaff = widget.assignStaff!;
      assignStaffCtrl.text = widget.assignStaff!;
    }
    if (widget.assignedUserId != null) {
      assignStaffId = widget.assignedUserId!;
    }

    if (widget.countryCode != null) {
      code = widget.countryCode!;
    }
    if (widget.whatsappCode != null) {
      whatsappCode = widget.whatsappCode!;
    } else if (widget.countryCode != null) {
      whatsappCode = widget.countryCode!;
    }

    if (widget.stateId != null) {
      StateId = widget.stateId;
    }
    if (widget.districtId != null) {
      DistrictId = widget.districtId;
    }
    _loadQuotationStaffs();
    _initializeData();
  }

  String _trimPlus91(String mobile) {
    if (mobile.startsWith('+91')) return mobile.substring(3);
    if (mobile.startsWith('91')) return mobile.substring(2);
    return mobile;
  }

  @override
  void dispose() {
    clientNameCtrl.dispose();
    contactNoCtrl.dispose();
    costCtrl.dispose();
    addressCtrl.dispose();
    remarkCtrl.dispose();
    pinCodeCtrl.dispose();
    nextFollowupCtrl.dispose();
    timeBeforeCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    callResponseCtrl.dispose();
    whatsappNoCtrl.dispose();
    emailCtrl.dispose();
    for (var ctrl in _additionalCtrls) ctrl.dispose();
    _scrollController.dispose();

    _pQuotationTitle.dispose();
    _pQuotation.dispose();
    _pClientName.dispose();
    _pPhone.dispose();
    _pLocation.dispose();
    _pElevatorType.dispose();
    _pTypeOfOpening.dispose();
    _pCapacity.dispose();
    _pPassengerCapacity.dispose();
    _pShaftWidth.dispose();
    _pShaftDepth.dispose();
    _pPitDepth.dispose();
    _pTravelHeight.dispose();
    _pOverheadHeight.dispose();
    _pWarranty.dispose();
    _pAmc.dispose();
    _pFactoryPrice.dispose();
    _pTransportation.dispose();
    _pInstallation.dispose();
    _pTesting.dispose();
    _pConsumables.dispose();
    _pAdditionalFactory.dispose();
    _pAdditional.dispose();
    _pAmcAmount.dispose();
    _pQuantity.dispose();
    _pUnitPrice.dispose();
    _pCompanyProfit.dispose();
    _pCompanyProfitAmount.dispose();
    _pSalesCommission.dispose();
    _pSalesCommissionAmount.dispose();
    _pSubTotal.dispose();
    _pTaxPercentage.dispose();
    _pTaxAmount.dispose();
    _pTotalSalePrice.dispose();
    _quotationTitleCtrl.dispose();
    _quotationMessageCtrl.dispose();

    super.dispose();
  }

  void _syncEstimationDefaults() {
    if (_pClientName.text.isEmpty && clientNameCtrl.text.isNotEmpty) {
      _pClientName.text = clientNameCtrl.text;
    }
    if (_pPhone.text.isEmpty && contactNoCtrl.text.isNotEmpty) {
      _pPhone.text = contactNoCtrl.text;
    }
    if (_pLocation.text.isEmpty) {
      if (districtCtrl.text.isNotEmpty) {
        _pLocation.text = districtCtrl.text;
      } else if (addressCtrl.text.isNotEmpty) {
        _pLocation.text = addressCtrl.text;
      }
    }
  }

  void _initEstimationFromData(dynamic data) {
    if (data == null) return;
    if (_pQuotationTitle.text.isEmpty &&
        data.quotationTitle != null &&
        data.quotationTitle!.isNotEmpty) {
      _pQuotationTitle.text = data.quotationTitle ?? '';
    }
    if (_pQuotation.text.isEmpty &&
        data.quotation != null &&
        data.quotation!.isNotEmpty) {
      _pQuotation.text = data.quotation ?? '';
    }
    if (_pClientName.text.isEmpty) {
      if (data.clientName != null && data.clientName!.isNotEmpty) {
        _pClientName.text = data.clientName ?? '';
      } else if (clientNameCtrl.text.isNotEmpty) {
        _pClientName.text = clientNameCtrl.text;
      }
    }
    if (_pPhone.text.isEmpty) {
      if (data.contactNumber1 != null && data.contactNumber1!.isNotEmpty) {
        _pPhone.text = data.contactNumber1 ?? '';
      } else if (contactNoCtrl.text.isNotEmpty) {
        _pPhone.text = contactNoCtrl.text;
      }
    }
    if (_pLocation.text.isEmpty) {
      if (data.location != null && data.location!.isNotEmpty) {
        _pLocation.text = data.location ?? '';
      } else if (districtCtrl.text.isNotEmpty) {
        _pLocation.text = districtCtrl.text;
      } else if (addressCtrl.text.isNotEmpty) {
        _pLocation.text = addressCtrl.text;
      }
    }
    if (_pElevatorType.text.isEmpty &&
        data.elevatorType != null &&
        data.elevatorType!.isNotEmpty) {
      _pElevatorType.text = data.elevatorType ?? '';
    }
    if (_pTypeOfOpening.text.isEmpty &&
        data.typeOfOpening != null &&
        data.typeOfOpening!.isNotEmpty) {
      _pTypeOfOpening.text = data.typeOfOpening ?? '';
    }
    if (_pCapacity.text.isEmpty &&
        data.capacity != null &&
        data.capacity!.isNotEmpty) {
      _pCapacity.text = data.capacity ?? '';
    }
    if (_pPassengerCapacity.text.isEmpty &&
        data.passengerCapacity != null &&
        data.passengerCapacity!.isNotEmpty) {
      _pPassengerCapacity.text = data.passengerCapacity ?? '';
    }
    if (_pShaftWidth.text.isEmpty &&
        data.shaftWidth != null &&
        data.shaftWidth!.isNotEmpty) {
      _pShaftWidth.text = data.shaftWidth ?? '';
    }
    if (_pShaftDepth.text.isEmpty &&
        data.shaftDepth != null &&
        data.shaftDepth!.isNotEmpty) {
      _pShaftDepth.text = data.shaftDepth ?? '';
    }
    if (_pPitDepth.text.isEmpty &&
        data.pitDepth != null &&
        data.pitDepth!.isNotEmpty) {
      _pPitDepth.text = data.pitDepth ?? '';
    }
    if (_pTravelHeight.text.isEmpty &&
        data.travelHeight != null &&
        data.travelHeight!.isNotEmpty) {
      _pTravelHeight.text = data.travelHeight ?? '';
    }
    if (_pOverheadHeight.text.isEmpty &&
        data.overheadHeight != null &&
        data.overheadHeight!.isNotEmpty) {
      _pOverheadHeight.text = data.overheadHeight ?? '';
    }
    if (_pWarranty.text.isEmpty &&
        data.warranty != null &&
        data.warranty!.isNotEmpty) {
      _pWarranty.text = data.warranty ?? '';
    }
    if (_pAmc.text.isEmpty && data.amc != null && data.amc!.isNotEmpty) {
      _pAmc.text = data.amc ?? '';
    }
    if (_pFactoryPrice.text.isEmpty &&
        data.factoryPrice != null &&
        data.factoryPrice!.isNotEmpty) {
      _pFactoryPrice.text = data.factoryPrice ?? '';
    }
    if (_pTransportation.text.isEmpty &&
        data.transportationCharge != null &&
        data.transportationCharge!.isNotEmpty) {
      _pTransportation.text = data.transportationCharge ?? '';
    }
    if (_pInstallation.text.isEmpty &&
        data.installationCharge != null &&
        data.installationCharge!.isNotEmpty) {
      _pInstallation.text = data.installationCharge ?? '';
    }
    if (_pTesting.text.isEmpty &&
        data.testingCharge != null &&
        data.testingCharge!.isNotEmpty) {
      _pTesting.text = data.testingCharge ?? '';
    }
    if (_pConsumables.text.isEmpty &&
        data.consumables != null &&
        data.consumables!.isNotEmpty) {
      _pConsumables.text = data.consumables ?? '';
    }
    if (_pAdditionalFactory.text.isEmpty &&
        data.additionalChargesApartFromFactory != null &&
        data.additionalChargesApartFromFactory!.isNotEmpty) {
      _pAdditionalFactory.text = data.additionalChargesApartFromFactory ?? '';
    }
    if (_pAdditional.text.isEmpty &&
        data.additionalCharge != null &&
        data.additionalCharge!.isNotEmpty) {
      _pAdditional.text = data.additionalCharge ?? '';
    }
    if (_pAmcAmount.text.isEmpty &&
        data.amcAmount != null &&
        data.amcAmount!.isNotEmpty) {
      _pAmcAmount.text = data.amcAmount ?? '';
    }
    if (_pUnitPrice.text.isEmpty &&
        data.unitPrice != null &&
        data.unitPrice!.isNotEmpty) {
      _pUnitPrice.text = data.unitPrice ?? '';
    }
    if (_pCompanyProfit.text.isEmpty &&
        data.companyProfit != null &&
        data.companyProfit!.isNotEmpty) {
      _pCompanyProfit.text = data.companyProfit ?? '';
    }
    if (_pCompanyProfitAmount.text.isEmpty &&
        data.companyProfitAmount != null &&
        data.companyProfitAmount!.isNotEmpty) {
      _pCompanyProfitAmount.text = data.companyProfitAmount ?? '';
    }
    if (_pSalesCommission.text.isEmpty &&
        data.salesCommission != null &&
        data.salesCommission!.isNotEmpty) {
      _pSalesCommission.text = data.salesCommission ?? '';
    }
    if (_pSalesCommissionAmount.text.isEmpty &&
        data.salesCommissionAmount != null &&
        data.salesCommissionAmount!.isNotEmpty) {
      _pSalesCommissionAmount.text = data.salesCommissionAmount ?? '';
    }
    if (_pSubTotal.text.isEmpty &&
        data.subTotal != null &&
        data.subTotal!.isNotEmpty) {
      _pSubTotal.text = data.subTotal ?? '';
    }
    if (_pTaxPercentage.text.isEmpty &&
        data.taxPercentage != null &&
        data.taxPercentage!.isNotEmpty) {
      _pTaxPercentage.text = data.taxPercentage ?? '';
    }
    if (_pTaxAmount.text.isEmpty &&
        data.taxAmount != null &&
        data.taxAmount!.isNotEmpty) {
      _pTaxAmount.text = data.taxAmount ?? '';
    }
    if (_pTotalSalePrice.text.isEmpty &&
        data.totalSalePrice != null &&
        data.totalSalePrice!.isNotEmpty) {
      _pTotalSalePrice.text = data.totalSalePrice ?? '';
    }

    _pLiftTypeId ??= _validSpecId(data.liftValues, data.liftType);
    _pOpeningId ??= _validSpecId(data.opening, data.openingName);
    _pDoorOpeningId ??= _validSpecId(data.cabinOpening, data.doorOpening);
    _pCabinSideWallId ??=
        _validSpecId(data.cabinSideWall, data.cabinSideWallName);
    _pLandingDoorId ??= _validSpecId(data.landingDoor, data.landingDoorName);
    _pCopId ??= _validSpecId(data.cop, data.copName);
    _pLopId ??= _validSpecId(data.lop, data.lopName);
    _pTaxType ??= (data.taxType != null && data.taxType!.isNotEmpty)
        ? data.taxType
        : null;
  }

  String? _validSpecId(List<dynamic>? list, String? id) {
    if (list == null || id == null || id.isEmpty) return null;
    return list.any((e) {
      if (e is CommonValue) return e.valueId == id;
      try {
        if (e.valueId != null) return e.valueId == id;
      } catch (_) {}
      return e.toString() == id;
    })
        ? id
        : null;
  }

  Map<String, dynamic> _buildPricingBody() {
    return <String, dynamic>{
      'quotation_title': _pQuotationTitle.text,
      'quotation': _pQuotation.text,
      'client_name': _pClientName.text.isNotEmpty
          ? _pClientName.text
          : clientNameCtrl.text,
      'phone': _pPhone.text.isNotEmpty ? _pPhone.text : contactNoCtrl.text,
      'location': _pLocation.text.isNotEmpty
          ? _pLocation.text
          : (districtCtrl.text.isNotEmpty
              ? districtCtrl.text
              : addressCtrl.text),
      'elevator_type': _pElevatorType.text,
      'type_of_opening': _pTypeOfOpening.text,
      'lift_capacity': _pCapacity.text,
      'no_of_passenger': _pPassengerCapacity.text,
      'shaft_width': _pShaftWidth.text,
      'shaft_depth': _pShaftDepth.text,
      'pit_depth': _pPitDepth.text,
      'travel_height': _pTravelHeight.text,
      'over_head_height': _pOverheadHeight.text,
      'lift_type': _pLiftTypeId ?? '',
      'opening_type': _pOpeningId ?? '',
      'door_opening': _pDoorOpeningId ?? '',
      'cabin_side_wall': _pCabinSideWallId ?? '',
      'landing_door': _pLandingDoorId ?? '',
      'cop': _pCopId ?? '',
      'lop': _pLopId ?? '',
      'wr': _pWarranty.text,
      'amc': _pAmc.text,
      'factory_price': _pFactoryPrice.text,
      'transportation': _pTransportation.text,
      'installation_charge': _pInstallation.text,
      'testing_commissioning': _pTesting.text,
      'consumables': _pConsumables.text,
      'additional_factory_charges': _pAdditionalFactory.text,
      'additional_amount': _pAdditional.text,
      'amc_amount': _pAmcAmount.text,
      'quantity': _pQuantity.text.isNotEmpty ? _pQuantity.text : '1',
      'price': _pUnitPrice.text,
      'tax_type': _pTaxType ?? '',
      'tax': _pTaxPercentage.text,
      'tax_amount': _pTaxAmount.text,
      'comp_profit': _pCompanyProfit.text,
      'comp_profit_amount': _pCompanyProfitAmount.text,
      'sales_commission': _pSalesCommission.text,
      'sales_commission_amount': _pSalesCommissionAmount.text,
      'sub_total': _pSubTotal.text,
      'grand_total': _pTotalSalePrice.text,
    };
  }

  Future<void> _initializeData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity is List<ConnectivityResult>) {
      if (!connectivity.contains(ConnectivityResult.mobile) &&
          !connectivity.contains(ConnectivityResult.wifi)) {
        setState(() => isLoading = false);
        return;
      }
    }

    contactPermission = await Common.getSharedPref("getContactPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    addLeadSource = await Common.getSharedPref("addLeadSource");

    if (assignStaff == 'Assign Staff' || assignStaff.isEmpty) {
      assignStaff = await Common.getSharedPref("name") ?? 'Assign Staff';
    }
    if (assignStaffId.isEmpty) {
      assignStaffId = await Common.getSharedPref("userId") ?? '';
    }

    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';

    final token = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (await Common.getSharedPref("token") ?? "");

    try {
      userPermissions = await HttpService.userPermissionCheck(token);

      log(
        'USER PERMISSION: '
        'createEstimation=${userPermissions?.data?.createEstimation}, '
        'createPricing=${userPermissions?.data?.createPricing}',
      );
    } catch (e) {
      log('Error fetching user permissions: $e');
    }

    commonDetails = await HttpService.addLeadCommonData(token);
    if (commonDetails != null) {
      if (widget.countryCode == null) {
        code = commonDetails!.data.countryCode.toString();
      }
      configure = await HttpService.configure(token);
    }
    stateDetails = await HttpService.getState();
    productSectionModel = await HttpService.leadProductSection();
    leadSourceModel = await HttpService.getLeadSourceAddleads();

    if (widget.products != null &&
        widget.products!.isNotEmpty &&
        productSectionModel?.data != null) {
      final productIds = widget.products!.split(',');
      _selectedProducts = productSectionModel!.data!
          .where((p) => productIds.any((id) => id.trim() == p.id))
          .toList();
    }

    if (leadTypeId.isNotEmpty) {
      leadSubTypeList = await HttpService.leadSubType(leadTypeId);
    }

    if (pinCodeCtrl.text.length == 6) {
      final model = await HttpService.fetchPostOffice(pinCodeCtrl.text);
      postOffices = model?.postOffice ?? [];
      if (postOffices.isNotEmpty && widget.postOffice != null) {
        try {
          selectedPostOffice = postOffices.firstWhere(
            (po) => po.name?.toLowerCase() == widget.postOffice!.toLowerCase(),
          );
        } catch (e) {
          // If not found, keep it null
        }
      }
    }

    if (StateId != null && StateId!.isNotEmpty) {
      final result = await HttpService.getDistrict(StateId!);
      districtList = result?.data ?? [];
    }

    try {
      estimationDetails = await HttpService.leadDetails(
        token,
        widget.leadMasterId ?? '',
      );
      if (estimationDetails?.data != null) {
        _initEstimationFromData(estimationDetails!.data);
      }
    } catch (e) {
      log("Error fetching estimation details: $e");
    }

    setState(() => isLoading = false);
  }

  String _formatDate(String dmy) {
    if (dmy.isEmpty) return dmy;
    final parts = dmy.split("-");
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', width: 150))
          : commonDetails == null || configure == null
              ? _buildNoNetworkView()
              : configure!.data!.isExpired == true
                  ? _buildExpiredView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.editLead == true ? 'Create Lead' : 'Create Lead',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildQuotationRequestForm() {
    return _buildSectionCard(
      title: 'Quotation Request',
      icon: Icons.request_quote_outlined,
      children: [
        const SizedBox(height: 12),
        TextFormField(
          controller: _quotationTitleCtrl,
          decoration: _inputDecoration(
            'Request Title *',
            Icons.title,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter request title';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _quotationMessageCtrl,
          maxLines: 3,
          decoration: _inputDecoration(
            'Request Message *',
            Icons.message_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter request message';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _quotationType,
          decoration: _inputDecoration(
            'Type *',
            Icons.category_outlined,
          ),
          items: const [
            DropdownMenuItem(
              value: "Amc",
              child: Text("Amc"),
            ),
            DropdownMenuItem(
              value: "General",
              child: Text("General"),
            ),
            DropdownMenuItem(
              value: "Repairing",
              child: Text("Repairing"),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _quotationType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select Type';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        isQuotationStaffLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                ),
              )
            : DropdownButtonFormField<String>(
                value: _quotationAssignedTo,
                decoration: _inputDecoration(
                  'Assigned To *',
                  Icons.person_outline,
                ),
                items: quotationStaffList.map((staff) {
                  return DropdownMenuItem<String>(
                    value: staff.userIdStaff,
                    child: Text(staff.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _quotationAssignedTo = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Assigned To';
                  }
                  return null;
                },
              ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildNoNetworkView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/noNetwork.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Text('No Network Found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          InkWell(
            onTap: _initializeData,
            child: Container(
              width: 120,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text('Try Again',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/main/packageimage.png',
              height: 160, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 15),
          const Text('Package Expired!',
              style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 10),
          const Text('Please contact support to upgrade your plan'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showUpgradeDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('UPGRADE'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (multiBranch == 'true' && roleId == '2') _buildBranchField(),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Customer Details',
              icon: Icons.person_outline,
              children: [
                const SizedBox(height: 12),
                _buildCustomerRow(),
                const SizedBox(height: 12),
                _buildPhoneField(),
                const SizedBox(height: 12),
                _buildWhatsappField(),
                const SizedBox(height: 12),
                _buildEmailField(),
                const SizedBox(height: 12),
                _buildAddressField(),
                const SizedBox(height: 12),
                _buildPinCodeField(),
                const SizedBox(height: 12),
                if (postOffices.isNotEmpty) _buildPostOfficeDropdown(),
                const SizedBox(height: 12),
                _buildLocationFields(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Lead Information',
              icon: Icons.info_outline,
              children: [
                const SizedBox(height: 12),
                _buildStaffField(),
                const SizedBox(height: 12),
                _buildLeadCategoryField(),
                const SizedBox(height: 12),
                if (leadSubTypeList?.data?.isNotEmpty ?? false)
                  _buildSubCategoryField(),
                const SizedBox(height: 12),
                _buildLeadSourceField(),
                const SizedBox(height: 12),
                _buildPriorityField(),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                _buildStatusField(),
                const SizedBox(height: 12),
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : (callResultId == '2'))
                  _buildFollowupRow(),
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : (callResultId == '2'))
                  const SizedBox(height: 12),
                _buildRemarksField(),
                const SizedBox(height: 12),
                // if (leadSettings != null
                //     ? leadSettings!.isFollowupRequiredBool ||
                //         callResultId == '2' ||
                //         callResultId == '3' ||
                //         callResultId == '4'
                //     : (callResultId == '2' ||
                //         callResultId == '3' ||
                //         callResultId == '4'))
                //   _buildCallResponseField(),
                if (callResultId != '1') _buildCallResponseField(),
              ],
            ),
            if (callResult == 'Estimation & Pricing' ||
                callResult.toLowerCase().contains('estimation')) ...[
              const SizedBox(height: 12),
              EstimationPricingCard(
                data: estimationDetails?.data,
                permissions: userPermissions,
                showPricing: true,
                initialClientName: clientNameCtrl.text,
                initialPhone: contactNoCtrl.text,
                initialLocation: districtCtrl.text.isNotEmpty
                    ? districtCtrl.text
                    : addressCtrl.text,
                quotationTitleCtrl: _pQuotationTitle,
                quotationCtrl: _pQuotation,
                clientNameCtrl: _pClientName,
                phoneCtrl: _pPhone,
                locationCtrl: _pLocation,
                elevatorTypeCtrl: _pElevatorType,
                typeOfOpeningCtrl: _pTypeOfOpening,
                capacityCtrl: _pCapacity,
                passengerCapacityCtrl: _pPassengerCapacity,
                shaftWidthCtrl: _pShaftWidth,
                shaftDepthCtrl: _pShaftDepth,
                pitDepthCtrl: _pPitDepth,
                travelHeightCtrl: _pTravelHeight,
                overheadHeightCtrl: _pOverheadHeight,
                warrantyCtrl: _pWarranty,
                amcCtrl: _pAmc,
                liftTypeId: _pLiftTypeId,
                openingId: _pOpeningId,
                doorOpeningId: _pDoorOpeningId,
                cabinSideWallId: _pCabinSideWallId,
                landingDoorId: _pLandingDoorId,
                copId: _pCopId,
                lopId: _pLopId,
                onLiftTypeChanged: (v) => setState(() => _pLiftTypeId = v),
                onOpeningChanged: (v) => setState(() => _pOpeningId = v),
                onDoorOpeningChanged: (v) =>
                    setState(() => _pDoorOpeningId = v),
                onCabinSideWallChanged: (v) =>
                    setState(() => _pCabinSideWallId = v),
                onLandingDoorChanged: (v) =>
                    setState(() => _pLandingDoorId = v),
                onCopChanged: (v) => setState(() => _pCopId = v),
                onLopChanged: (v) => setState(() => _pLopId = v),
                factoryPriceCtrl: _pFactoryPrice,
                transportationCtrl: _pTransportation,
                installationCtrl: _pInstallation,
                testingCtrl: _pTesting,
                consumablesCtrl: _pConsumables,
                additionalFactoryCtrl: _pAdditionalFactory,
                additionalCtrl: _pAdditional,
                amcAmountCtrl: _pAmcAmount,
                quantityCtrl: _pQuantity,
                unitPriceCtrl: _pUnitPrice,
                companyProfitCtrl: _pCompanyProfit,
                companyProfitAmountCtrl: _pCompanyProfitAmount,
                salesCommissionCtrl: _pSalesCommission,
                salesCommissionAmountCtrl: _pSalesCommissionAmount,
                subTotalCtrl: _pSubTotal,
                taxPercentageCtrl: _pTaxPercentage,
                taxAmountCtrl: _pTaxAmount,
                totalSalePriceCtrl: _pTotalSalePrice,
                taxType: _pTaxType,
                onTaxTypeChanged: (v) => setState(() => _pTaxType = v),
              ),
              const SizedBox(height: 12),
              if (leadType == 'SUPPLY AND INSTALLATION' ||
                  leadType == 'AMC' ||
                  leadType == 'Repair') ...[
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Create Quotation Request',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: _sendQuotation,
                  onChanged: (value) {
                    setState(() {
                      _sendQuotation = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_sendQuotation) _buildQuotationRequestForm(),
              ],
            ],
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Product Info',
              icon: Icons.shopping_bag_outlined,
              children: [
                const SizedBox(height: 12),
                _buildProductSelection(),
                const SizedBox(height: 12),
                _buildCostField(),
              ],
            ),
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Additional Fields',
                icon: Icons.more_horiz,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFields(),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSubmitButton()),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchField() {
    return DropdownButtonFormField<String>(
      value: branch,
      decoration: _inputDecoration('Select Branch *', Icons.business),
      items: commonDetails!.data.branch.map((b) {
        return DropdownMenuItem(
          value: b.branchId.toString(),
          child: Text(b.branchName!),
        );
      }).toList(),
      onChanged: (value) async {
        setState(() => branch = value);
        commonDetails =
            await HttpService.addLeadCommonData(widget.token, branchId: branch);
        setState(() {});
      },
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: clientNameCtrl,
            decoration: _inputDecoration('Client Name *', Icons.person),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => contactPermission == 'true'
              ? _selectContact()
              : _showPermissionDialog(),
          child: Container(
            height: 50,
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.contacts, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: contactNoCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        label: RichText(
          text: const TextSpan(
            text: 'Contact Number ',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(text: '*', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (c) => setState(() => code = c.phoneCode),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text("+$code"), const Icon(Icons.arrow_drop_down)],
            ),
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (v!.isEmpty) return 'Required';
        if (code == '91' && v.length != 10) return '10 digits required';
        return null;
      },
    );
  }

  Widget _buildWhatsappField() {
    return TextFormField(
      controller: whatsappNoCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Whatsapp Number',
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (c) => setState(() => whatsappCode = c.phoneCode),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("+$whatsappCode"),
                const Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (whatsappCode == '91' &&
            v != null &&
            v.isNotEmpty &&
            v.length != 10) {
          return 'Enter 10 digit number';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('Email', Icons.email),
      validator: (v) {
        if (v != null && v.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
            return 'Enter valid email';
          }
        }
        return null;
      },
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: costCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('Cost', Icons.currency_rupee),
    );
  }

  Widget _buildStaffField() {
    return GestureDetector(
      onTap: () => _showStaffDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: assignStaff),
          decoration: _inputDecoration('Assign Staff', Icons.person),
        ),
      ),
    );
  }

  Widget _buildLeadCategoryField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () => _showCategoryDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: leadTypeCtrl,
              decoration: _inputDecoration(
                      'Lead Category', Icons.arrow_drop_down_circle_outlined)
                  .copyWith(
                suffixIcon: leadTypeId.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            leadType = 'Lead Category';
                            leadTypeId = '';
                            leadSubType = 'Lead Sub Category';
                            leadSubTypeId = '';
                            leadSubTypeList = null;
                          });
                        },
                      )
                    : null,
              ),
              validator: (value) {
                if (leadTypeId.isEmpty) {
                  return 'Please select Lead Category';
                }
                return null;
              },
            ),
          ),
        ),
        if (createLeadCategory == 'true')
          Positioned(
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddCategoryDialog(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubCategoryField() {
    return GestureDetector(
      onTap: () => _showSubCategoryDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: leadSubTypeCtrl,
          decoration: _inputDecoration(
              'Lead Sub Category', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildLeadSourceField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () => _showSourceDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: leadSourceCtrl,
              decoration: _inputDecoration(
                  'Lead Source', Icons.arrow_drop_down_circle_outlined),
            ),
          ),
        ),
        if (addLeadSource == 'true')
          Positioned(
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddSourceDialog(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityField() {
    return GestureDetector(
      onTap: () => _showPriorityDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: priorityCtrl,
          decoration: _inputDecoration(
              'Priority', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Address', Icons.location_on_outlined),
    );
  }

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: pinCodeCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('PIN Code', Icons.pin_drop).copyWith(
        suffixIcon: isPinLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : null,
      ),
      onChanged: (v) async {
        if (v.length == 6) {
          setState(() => isPinLoading = true);
          final model = await HttpService.fetchPostOffice(v);
          setState(() {
            isPinLoading = false;
            postalCodeModel = model;
            postOffices = model?.postOffice ?? [];
          });
        } else {
          setState(() {
            postOffices = [];
            selectedPostOffice = null;
          });
        }
      },
    );
  }

  Widget _buildPostOfficeDropdown() {
    return DropdownButtonFormField<PostOffice>(
      value: selectedPostOffice,
      decoration:
          _inputDecoration('Select Post Office', Icons.local_post_office),
      items: postOffices.map((po) {
        return DropdownMenuItem(value: po, child: Text(po.name ?? ''));
      }).toList(),
      onChanged: (v) => setState(() => selectedPostOffice = v),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showStateDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: stateCtrl,
              decoration: _inputDecoration(
                  'State', Icons.arrow_drop_down_circle_outlined),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isDistrictLoading)
          const Center(child: CircularProgressIndicator())
        else if (districtList.isNotEmpty)
          DropdownButtonFormField<DistrictList>(
            value: districtList.any((d) => d.id == DistrictId)
                ? districtList.firstWhere((d) => d.id == DistrictId)
                : null,
            decoration: _inputDecoration(
                'Select District', Icons.arrow_drop_down_circle_outlined),
            hint: const Text("Select District"),
            items: districtList.map((d) {
              return DropdownMenuItem(value: d, child: Text(d.name));
            }).toList(),
            onChanged: (v) => setState(() {
              DistrictId = v?.id;
              districtCtrl.text = v?.name ?? '';
            }),
          ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: remarkCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Remarks', Icons.list),
    );
  }

  Widget _buildStatusField() {
    return GestureDetector(
      onTap: () => _showCallResultDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: callResult),
          decoration:
              _inputDecoration('Stages', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildCallResponseField() {
    return GestureDetector(
      onTap: () => _showCallResponseDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResponseCtrl,
          decoration: _inputDecoration('Call Response *', Icons.add_call),
        ),
      ),
    );
  }

  Widget _buildFollowupRow() {
    return Row(
      children: [
        Expanded(
          flex: checked ? 3 : 4,
          child: TextFormField(
            controller: nextFollowupCtrl,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final now = DateTime.now();
                  final selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );

                  if (selectedDateTime.isAfter(now)) {
                    nextFollowupCtrl.text =
                        "${_formatDate(date.toString().split(' ')[0])} ${time.format(context)}";
                  } else {
                    Common.toastMessaage(
                      'You cannot choose a past time for the follow-up date',
                      Colors.red,
                    );
                  }
                }
              }
            },
            decoration:
                _inputDecoration('Next Followup Date', Icons.calendar_month),
          ),
        ),
        if (checked)
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: timeBeforeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        int val = int.parse(timeBeforeCtrl.text);
                        timeBeforeCtrl.text = (val + 1).toString();
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 20),
                    ),
                    InkWell(
                      onTap: () {
                        int val = int.parse(timeBeforeCtrl.text);
                        timeBeforeCtrl.text =
                            (val > 0 ? val - 1 : 0).toString();
                      },
                      child: const Icon(Icons.arrow_drop_down, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => setState(() => checked = !checked),
          child: Icon(
            Icons.notifications,
            color: checked ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAdditionalFields() {
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      _additionalCtrls.add(TextEditingController());
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _additionalCtrls[i],
          onSaved: (v) {
            _additionalValues.add({
              "id": commonDetails!.data.additionalFields[i].id,
              "name": commonDetails!.data.additionalFields[i].fieldName,
              "value": v,
            });
          },
          decoration: _inputDecoration(
            commonDetails!.data.additionalFields[i].fieldName,
            Icons.arrow_drop_down_circle,
          ),
        ),
      );
    });
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2a86c9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Create Lead',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showProductPopup(),
                child: AbsorbPointer(
                  child: TextFormField(
                    key: ValueKey(_selectedProducts.length),
                    initialValue: _selectedProducts.isEmpty
                        ? ''
                        : "${_selectedProducts.length} Products Selected",
                    decoration: _inputDecoration(
                        'Select Products', Icons.shopping_cart,
                        isDense: true),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProducts(),
                    )).then((_) {
                  _initializeData();
                });
              },
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedProducts.isNotEmpty)
          Column(
            children: _selectedProducts.map((p) {
              bool isExpanded = _expandedProductId == p.id;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_expandedProductId == p.id) {
                          _expandedProductId = null;
                        } else {
                          _expandedProductId = p.id;
                          if (p.id != null) {
                            _fetchProductDescription(p.id!);
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${p.productName} - Rs ${p.totalAmount}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2a86c9)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeProduct(p),
                            child: const Icon(Icons.cancel,
                                size: 20, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded &&
                      (_descriptionLoading[p.id] == true ||
                          (_productDescriptions[p.id]?.isNotEmpty ?? false)))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin:
                          const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Product Description",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          _descriptionLoading[p.id] == true
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  _productDescriptions[p.id] ?? "",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showProductPopup() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (productSectionModel == null ||
        productSectionModel!.data == null ||
        productSectionModel!.data!.isEmpty) {
      Common.toastMessaage('No Products found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(productSectionModel!.data!);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select Products'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = productSectionModel!.data!
                          .where((p) => (p.productName ?? "")
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        bool isSelected =
                            _selectedProducts.any((item) => item.id == p.id);
                        return ListTile(
                          title: Text(p.productName ?? ''),
                          subtitle: Text("Rs ${p.totalAmount}"),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            if (isSelected) {
                              _removeProduct(p);
                            } else {
                              _addProduct(p);
                            }
                            setDialogState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('DONE'),
              ),
            ],
          );
        });
      },
    );
  }

  void _addProduct(LeadProduct p) {
    setState(() {
      if (!_selectedProducts.any((item) => item.id == p.id)) {
        _selectedProducts.add(p);
      }
      _calculateTotalAmount();
    });
  }

  void _removeProduct(LeadProduct p) {
    setState(() {
      _selectedProducts.removeWhere((item) => item.id == p.id);
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    double total = 0;
    for (var p in _selectedProducts) {
      String amountStr = (p.totalAmount ?? '0').replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    costCtrl.text = total.toStringAsFixed(2);
  }

  InputDecoration _inputDecoration(String? label, IconData icon,
      {bool isDense = false}) {
    return InputDecoration(
      isDense: isDense,
      label: RichText(
        text: TextSpan(
          text: (label ?? "").replaceAll(' *', ''),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            if (label?.contains('*') == true)
              const TextSpan(
                text: ' *',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 12, vertical: isDense ? 8 : 14),
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
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  // Dialog Methods
  void _showStaffDialog() {
    FocusManager.instance.primaryFocus?.unfocus();

    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();

        List<StaffListData> staffList = [];
        List<StaffListData> filtered = [];

        bool isLoading = true;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            // Load API only once
            if (isLoading && staffList.isEmpty) {
              isLoading = false;

              HttpService.getStaffList().then((response) {
                if (response != null && response.status) {
                  setDialogState(() {
                    staffList = response.data;
                    filtered = List.from(staffList);
                  });
                }
              });
            }

            return AlertDialog(
              title: const Text('Assign Staff'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (v) {
                        setDialogState(() {
                          filtered = staffList
                              .where(
                                (s) => s.staffName
                                    .toLowerCase()
                                    .contains(v.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : filtered.isEmpty
                              ? const Center(
                                  child: Text('No staff found'),
                                )
                              : ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) {
                                    final staff = filtered[i];

                                    return ListTile(
                                      title: Text(staff.staffName),
                                      subtitle: staff.branchName != null
                                          ? Text(staff.branchName!)
                                          : null,
                                      onTap: () {
                                        assignStaff = staff.staffName;
                                        assignStaffId = staff.userId;

                                        Navigator.pop(context);

                                        setState(() {});
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

  void _showCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.leadCategory);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Lead Category'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = commonDetails!.data.leadCategory
                          .where((c) => c.leadCategory
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final cat = filtered[i];
                        return ListTile(
                          title: Text(cat.leadCategory),
                          onTap: () async {
                            leadSubTypeList = await HttpService.leadSubType(
                                cat.leadCategoryId.toString());
                            setState(() {
                              leadType = cat.leadCategory;
                              leadTypeCtrl.text = leadType;
                              leadTypeId = cat.leadCategoryId.toString();
                              leadSubType = 'Lead Sub Category';
                              leadSubTypeCtrl.text = leadSubType;
                              leadSubTypeId = '';
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
        });
      },
    );
  }

  void _showSubCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (leadSubTypeList == null ||
        leadSubTypeList!.data == null ||
        leadSubTypeList!.data!.isEmpty) {
      Common.toastMessaage('No Sub Category found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Lead Sub Category'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: ListView.builder(
              itemCount: leadSubTypeList!.data!.length,
              itemBuilder: (_, i) {
                final sub = leadSubTypeList!.data![i];
                return ListTile(
                  title: Text(sub.leadSubCategory ?? ''),
                  onTap: () {
                    setState(() {
                      leadSubType = sub.leadSubCategory!;
                      leadSubTypeCtrl.text = leadSubType;
                      leadSubTypeId = sub.leadSubCategoryId.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(leadSourceModel?.data ?? []);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Lead Source'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = (leadSourceModel?.data ?? [])
                          .where((s) => (s.leadSource ?? "")
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final src = filtered[i];
                        return ListTile(
                          title: Text(src.leadSource ?? ""),
                          onTap: () {
                            setState(() {
                              leadSource = src.leadSource ?? "";
                              leadSourceCtrl.text = leadSource;
                              leadSourceId = src.leadSourceId ?? "";
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
        });
      },
    );
  }

  void _showPriorityDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Priority'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 200,
            child: ListView.builder(
              itemCount: commonDetails!.data.priority.length,
              itemBuilder: (_, i) {
                final p = commonDetails!.data.priority[i];
                return ListTile(
                  title: Text(p.priority),
                  onTap: () {
                    setState(() {
                      priority = p.priority;
                      priorityCtrl.text = priority;
                      priorityId = p.priorityId.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCallResultDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Stages'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: ListView.builder(
              itemCount: commonDetails!.data.callResult.length,
              itemBuilder: (_, i) {
                final cr = commonDetails!.data.callResult[i];
                return ListTile(
                  title: Text(cr.callResult),
                  onTap: () {
                    setState(() {
                      callResult = cr.callResult;
                      callResultCtrl.text = callResult;
                      callResultId = cr.callResultId.toString();
                      if (callResultId != '2') nextFollowupCtrl.clear();
                      _fetchLeadExtraSettings(callResultId);
                      if (callResult == 'Estimation & Pricing' ||
                          callResult.toLowerCase().contains('estimation')) {
                        _syncEstimationDefaults();
                        if (estimationDetails == null ||
                            estimationDetails?.data?.liftValues == null) {
                          _fetchEstimationDetails();
                        }
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchEstimationDetails() async {
    try {
      final token = (widget.token != null && widget.token!.isNotEmpty)
          ? widget.token!
          : (await Common.getSharedPref("token") ?? "");
      final res = await HttpService.leadDetails(
        token,
        widget.leadMasterId ?? '',
      );
      if (mounted && res != null) {
        setState(() {
          estimationDetails = res;
          if (res.data != null) {
            _initEstimationFromData(res.data);
          }
        });
      }
    } catch (e) {
      log("Error fetching estimation details: $e");
    }
  }

  void _showCallResponseDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.callResponseStatus);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Call Response'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = commonDetails!.data.callResponseStatus
                          .where((r) => r.callResponse
                              .toString()
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final r = filtered[i];
                        return ListTile(
                          title: Text(r.callResponse.toString()),
                          onTap: () {
                            setState(() {
                              callResponse = r.callResponse.toString();
                              callResponseId = r.callResponseId.toString();
                              callResponseCtrl.text = callResponse;
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
        });
      },
    );
  }

  void _showStateDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(stateDetails!.data);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select State'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = stateDetails!.data
                          .where((s) =>
                              s.name.toLowerCase().contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return ListTile(
                          title: Text(s.name),
                          onTap: () async {
                            Navigator.pop(context);
                            setState(() {
                              stateCtrl.text = s.name;
                              StateId = s.id;
                              DistrictId = null;
                              districtCtrl.clear();
                              districtList = [];
                              isDistrictLoading = true;
                            });
                            final result = await HttpService.getDistrict(s.id);
                            setState(() {
                              districtList = result?.data ?? [];
                              isDistrictLoading = false;
                              DistrictId = null;
                              districtCtrl.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showAddCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadCategoryDialog(
        onSubmit: (name, cost, sub) async {
          final token = await Common.getSharedPref('token');
          final response = await HttpService.postLeadCategory(name, cost, sub);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(token);
            if (commonDetails != null) {
              try {
                final newCat = commonDetails!.data.leadCategory.firstWhere(
                  (c) => c.leadCategory.toLowerCase() == name.toLowerCase(),
                );
                setState(() {
                  leadType = newCat.leadCategory;
                  leadTypeCtrl.text = leadType;
                  leadTypeId = newCat.leadCategoryId.toString();
                  if (cost.isNotEmpty) {
                    costCtrl.text = cost;
                  }
                  leadSubType = 'Lead Sub Category';
                  leadSubTypeCtrl.text = leadSubType;
                  leadSubTypeId = '';
                });

                // Load sub-categories for the new category
                leadSubTypeList = await HttpService.leadSubType(leadTypeId);

                if (sub != null &&
                    sub.isNotEmpty &&
                    leadSubTypeList?.data != null) {
                  try {
                    final newSub = leadSubTypeList!.data!.firstWhere(
                      (s) =>
                          s.leadSubCategory?.toLowerCase() == sub.toLowerCase(),
                    );
                    setState(() {
                      leadSubType = newSub.leadSubCategory!;
                      leadSubTypeCtrl.text = leadSubType;
                      leadSubTypeId = newSub.leadSubCategoryId.toString();
                    });
                  } catch (e) {
                    // Sub-category not found in refreshed list
                  }
                }
              } catch (e) {
                // Category not found in refreshed list
              }
            }
            setState(() {});
            // Navigator.pop(context); // REMOVED: AddLeadCategoryDialog already pops itself
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Category added'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadSourceDialog(
        onSubmit: (name) async {
          final token = await Common.getSharedPref('token');
          final response = await HttpService.postLeadSource(name);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(token);
            leadSourceModel = await HttpService.getLeadSourceAddleads();
            if (commonDetails != null) {
              try {
                final newSrc = leadSourceModel!.data!.firstWhere(
                  (s) => s.leadSource?.toLowerCase() == name.toLowerCase(),
                );
                setState(() {
                  leadSource = newSrc.leadSource ?? "";
                  leadSourceCtrl.text = leadSource;
                  leadSourceId = newSrc.leadSourceId ?? "";
                });
              } catch (e) {
                // Source not found in refreshed list
              }
            }
            setState(() {});
            // Navigator.pop(context); // REMOVED: AddLeadSourceDialog already pops itself
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Permission',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 15),
                const Text(
                  'Access contacts to manage them efficiently',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Deny',
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Common.saveSharedPref('getContactPermission', 'true');
                        contactPermission = 'true';
                        _selectContact();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Allow'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upgrade Package'),
        content: const Text('Contact support to upgrade your plan'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('tel:${configure!.data!.supportTeamNumber}'),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String number =
            contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
        if (number.startsWith('+'))
          number = number.substring(number.length - 10);
        else if (number.length > 10)
          number = number.substring(number.length - 10);
        setState(() {
          contactNoCtrl.text = number;
          clientNameCtrl.text = contact.displayName;
        });
      }
    } else {
      Common.toastMessaage('Permission denied', Colors.red);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }
    _formKey.currentState!.save();

    if (multiBranch == 'true' && roleId == '2' && branch == null) {
      Common.toastMessaage('Select Branch', Colors.red);
      return;
    }

    bool nextFollowUpRequired =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (nextFollowUpRequired && nextFollowupCtrl.text.isEmpty) {
      Common.toastMessaage('Select followup date', Colors.red);
      return;
    }

    if (callResultId != '1' && callResponseId.isEmpty) {
      Common.toastMessaage('Select call response', Colors.red);
      return;
    }

    final isEstimationStage = callResult == 'Estimation & Pricing' ||
        callResult.toLowerCase().contains('estimation');
    if (isEstimationStage) {
      // if (_pQuotation.text.trim().isEmpty) {
      //   Common.toastMessaage('Quotation Name is required', Colors.red);
      //   return;
      // }
    }

    Common.showProgressDialog(context, 'Loading...');
    final check = await HttpService.checkLeadPhoneNumber(
        widget.token, contactNoCtrl.text, code);

    if (check.data == true) {
      Navigator.pop(context);
      _showDuplicateDialog(check.message ?? 'Number already exists. Continue?');
    } else {
      await _submitLead();
    }
  }

  void _showDuplicateDialog(String message) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alert!'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Common.showProgressDialog(context, 'Loading...');
              await _submitLead();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLead() async {
    String productIds =
        _selectedProducts.map((p) => p.id).where((id) => id != null).join(',');

    final isEstimationStage = callResult == 'Estimation & Pricing' ||
        callResult.toLowerCase().contains('estimation');
    final pricingBody = isEstimationStage ? _buildPricingBody() : null;

    final result = await HttpService.addLeadsNew(
      widget.token,
      branch,
      clientNameCtrl.text,
      leadTypeId,
      leadSubTypeId,
      contactNoCtrl.text,
      assignStaffId,
      costCtrl.text,
      priorityId,
      addressCtrl.text,
      pinCodeCtrl.text,
      selectedPostOffice?.name ?? '',
      remarkCtrl.text,
      callResultId,
      callResponseId,
      nextFollowupCtrl.text,
      _additionalValues,
      code,
      checked,
      timeBeforeCtrl.text,
      leadSourceId,
      stateId: StateId,
      districtId: DistrictId,
      products: productIds,
      whatsappNumber: whatsappNoCtrl.text,
      whatsappnumber_country_code: whatsappCode,
      email: emailCtrl.text,
      pricingData: pricingBody,
    );
    print("ADD LEAD RESPONSE: ${result.status}");
    print("ADD LEAD MESSAGE: ${result.message}");

    Navigator.pop(context);
    if (result.status == true) {
      Common.toastMessaage(result.message, Colors.green);

      // if (isEstimationStage && _sendQuotation) {
      //   final quotationSent = await _sendQuotationRequest();

      //   if (!quotationSent) {
      //     return;
      //   }
      // }

      if (!mounted) return;

      Navigator.pop(context);
    } else {
      Common.toastMessaage(result.message, Colors.red);
    }
  }
}
