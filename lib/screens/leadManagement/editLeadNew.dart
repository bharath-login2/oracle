import 'dart:convert';
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
import 'package:login2/screens/product_mannagement/add_products.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/getLeadSourceModel.dart';
import '../../models/userPermissionModel.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import 'package:login2/models/expense/staffListModel.dart' as expense;
import 'package:login2/widgets/estimation_pricing_card.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadExtraSettings.dart';
import 'dart:developer';

class EditLeadNew extends StatefulWidget {
  final String? token;
  final String callMasterId;
  final bool editLeads;
  final bool deleteLeads;
  final bool cloudCall;
  final String? fromDate;
  final String? toDate;
  final String? status;
  final String? category;
  final String? staff;
  final String? pageName;
  final bool? isCalled;
  final int? scrolToIndex;

  const EditLeadNew(
    this.token,
    this.callMasterId,
    this.editLeads,
    this.deleteLeads,
    this.cloudCall, {
    super.key,
    this.fromDate,
    this.toDate,
    this.status,
    this.category,
    this.staff,
    this.pageName,
    this.isCalled,
    this.scrolToIndex,
  });

  @override
  State<EditLeadNew> createState() => _EditLeadNewState();
}

class _EditLeadNewState extends State<EditLeadNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  LeadDeatailsModel? leadDetails;
  UserPermissionModel? userPermissions;
  GetLeadSourceModel? leadSourceModel;
  final ScrollController _scrollController = ScrollController();

  // Form Fields
  String leadType = 'Lead Category', leadTypeId = '';
  String leadSubType = 'Sub Category', leadSubTypeId = '';
  String assignStaff = 'Assign Staff', assignStaffId = '';
  String leadSource = 'Lead Source', leadSourceId = '';
  String priority = 'Priority', priorityId = '';
  String callResult = 'New', callResultId = '1';
  String callResponse = 'Call Response', callResponseId = '';

  final TextEditingController leadTypeCtrl =
      TextEditingController(text: 'Lead Category');
  final TextEditingController leadSubTypeCtrl =
      TextEditingController(text: 'Sub Category');
  final TextEditingController assignStaffCtrl =
      TextEditingController(text: 'Assign Staff');
  final TextEditingController leadSourceCtrl =
      TextEditingController(text: 'Lead Source');
  final TextEditingController priorityCtrl =
      TextEditingController(text: 'Priority');
  final TextEditingController callResultCtrl =
      TextEditingController(text: 'New');
  final TextEditingController callResponseCtrl = TextEditingController();

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
  final TextEditingController _pDoorOpeningSize = TextEditingController();
  final TextEditingController _pWarranty = TextEditingController();
  final TextEditingController _pAmc = TextEditingController();

  String? _amcTypeSelected;
  final TextEditingController _amcTypeCtrl = TextEditingController();
  final TextEditingController _liftBrandCtrl = TextEditingController();
  final TextEditingController _ageOfLiftCtrl = TextEditingController();
  final TextEditingController _amcPriceCtrl = TextEditingController();

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

  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];

  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  LeadProductSectionModel? productSectionModel;
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
    setState(() => isQuotationStaffLoading = true);
    try {
      final response = await HttpService.getStaffs();
      if (mounted) {
        setState(() {
          quotationStaffList = (response != null && response.status) ? response.data : [];
          isQuotationStaffLoading = false;
        });
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
          _productDescriptions[productId] =
              (response != null && response.status == true) ? response.data : "";
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
          leadSettings = (response != null && response.status == true)
              ? response.data.settings
              : null;
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
    _loadQuotationStaffs();
    _initializeData();
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
    leadTypeCtrl.dispose();
    leadSubTypeCtrl.dispose();
    assignStaffCtrl.dispose();
    leadSourceCtrl.dispose();
    priorityCtrl.dispose();
    callResultCtrl.dispose();
    for (var ctrl in _additionalCtrls) {
      ctrl.dispose();
    }
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
    _amcTypeCtrl.dispose();
    _liftBrandCtrl.dispose();
    _ageOfLiftCtrl.dispose();
    _amcPriceCtrl.dispose();
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

    Map<String, dynamic> addFieldsMap = {};
    if (data.additionalFields != null) {
      if (data.additionalFields is Map<String, dynamic>) {
        addFieldsMap = data.additionalFields;
      } else if (data.additionalFields is String &&
          data.additionalFields.toString().isNotEmpty) {
        try {
          addFieldsMap = jsonDecode(data.additionalFields.toString());
        } catch (_) {}
      }
    }

    Map<String, dynamic> amcMap = data.amcDetails ?? {};
    Map<String, dynamic> pricingMap = data.rawJson != null &&
            data.rawJson['leadPricing'] is Map<String, dynamic>
        ? data.rawJson['leadPricing']
        : {};
    Map<String, dynamic> quotationMap = data.rawJson != null &&
            data.rawJson['lift_quotation'] is Map<String, dynamic>
        ? data.rawJson['lift_quotation']
        : {};

    // AMC Type
    final amcVal = amcMap['amc_type']?.toString() ??
        addFieldsMap['amc_type']?.toString() ??
        pricingMap['amc']?.toString() ??
        quotationMap['amc']?.toString() ??
        data.amc;
    if (amcVal != null && amcVal.isNotEmpty) {
      _amcTypeSelected = amcVal;
      _amcTypeCtrl.text = amcVal;
      _pAmc.text = amcVal;
    }

    // Lift Brand / Elevator Type
    final brandVal = amcMap['lift_brand']?.toString() ??
        addFieldsMap['lift_brand']?.toString() ??
        pricingMap['elevator_type']?.toString() ??
        quotationMap['elevator_type']?.toString() ??
        data.elevatorType;
    if (brandVal != null && brandVal.isNotEmpty) {
      _liftBrandCtrl.text = brandVal;
      _pElevatorType.text = brandVal;
    }

    // Age of Lift / Warranty
    final ageVal = amcMap['age_of_lift']?.toString() ??
        addFieldsMap['age_of_lift']?.toString() ??
        pricingMap['wr']?.toString() ??
        quotationMap['wr']?.toString() ??
        data.warranty;
    if (ageVal != null && ageVal.isNotEmpty) {
      _ageOfLiftCtrl.text = ageVal;
      _pWarranty.text = ageVal;
    }

    // Subject / Quotation Title
    final subjVal = amcMap['amc_subject']?.toString() ??
        addFieldsMap['amc_subject']?.toString() ??
        pricingMap['quotation_title']?.toString() ??
        quotationMap['quotation_title']?.toString() ??
        data.quotationTitle;
    if (subjVal != null && subjVal.isNotEmpty) {
      _pQuotationTitle.text = subjVal;
      if (_quotationTitleCtrl.text.isEmpty ||
          _quotationTitleCtrl.text == "Quotation Request") {
        _quotationTitleCtrl.text = subjVal;
      }
    }

    // Passenger Capacity
    final passCapVal = amcMap['amc_passenger_capacity']?.toString() ??
        addFieldsMap['amc_passenger_capacity']?.toString() ??
        pricingMap['no_of_passenger']?.toString() ??
        quotationMap['no_of_passenger']?.toString() ??
        data.passengerCapacity;
    if (passCapVal != null && passCapVal.isNotEmpty) {
      _pPassengerCapacity.text = passCapVal;
    }

    // Price / AMC Amount
    final priceVal = amcMap['amc_price']?.toString() ??
        addFieldsMap['amc_price']?.toString() ??
        pricingMap['amc_amount']?.toString() ??
        pricingMap['price']?.toString() ??
        pricingMap['grand_total']?.toString() ??
        quotationMap['amc_amount']?.toString() ??
        quotationMap['price']?.toString() ??
        data.amcAmount ??
        data.unitPrice ??
        data.totalSalePrice;
    if (priceVal != null && priceVal.isNotEmpty) {
      _amcPriceCtrl.text = priceVal;
      _pAmcAmount.text = priceVal;
      _pUnitPrice.text = priceVal;
      _pTotalSalePrice.text = priceVal;
    }

    // Checkbox Send Quotation / Quote Request
    final sendQuote = data.sendQuoteRequest == true ||
        data.quoteRequestSts == "1" ||
        (data.rawJson != null &&
            data.rawJson['quote_request_sts']?.toString() == "1") ||
        data.callResultId == "17" ||
        (data.callResult != null &&
            data.callResult.toLowerCase().contains("quotation"));

    _sendQuotation = sendQuote;

    // Request Title & Message
    final reqTitle = data.requestTitle ??
        pricingMap['request_title'] ??
        quotationMap['quotation_title'] ??
        subjVal;
    if (reqTitle != null && reqTitle.isNotEmpty) {
      _quotationTitleCtrl.text = reqTitle;
    }

    final reqMsg = data.requestMessage ?? pricingMap['request_message'];
    if (reqMsg != null && reqMsg.isNotEmpty) {
      _quotationMessageCtrl.text = reqMsg;
    }

    final qType = data.quotationType ??
        pricingMap['quotation_type'] ??
        (data.leadCategory?.toUpperCase() == 'AMC' ? "Amc" : "General");
    if (qType != null && qType.isNotEmpty) {
      _quotationType = qType;
    }

    final qAssigned = data.quotationAssignedTo ??
        pricingMap['quotation_assigned_to'] ??
        data.assignedUserId;
    if (qAssigned != null && qAssigned.isNotEmpty) {
      _quotationAssignedTo = qAssigned;
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
    if (_pDoorOpeningSize.text.isEmpty &&
        data.doorOpeningSize != null &&
        data.doorOpeningSize!.isNotEmpty) {
      _pDoorOpeningSize.text = data.doorOpeningSize ?? '';
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
    final elevatorTypeVal = _liftBrandCtrl.text.trim().isNotEmpty
        ? _liftBrandCtrl.text
        : _pElevatorType.text;
    final amcTypeVal = _amcTypeCtrl.text.trim().isNotEmpty
        ? _amcTypeCtrl.text
        : _pAmc.text;
    final amcAmountVal = _amcPriceCtrl.text.trim().isNotEmpty
        ? _amcPriceCtrl.text
        : (_pAmcAmount.text.isNotEmpty ? _pAmcAmount.text : _pUnitPrice.text);
    final unitPriceVal = _amcPriceCtrl.text.trim().isNotEmpty
        ? _amcPriceCtrl.text
        : _pUnitPrice.text;
    final grandTotalVal = _amcPriceCtrl.text.trim().isNotEmpty
        ? _amcPriceCtrl.text
        : _pTotalSalePrice.text;
    final warrantyVal = _ageOfLiftCtrl.text.trim().isNotEmpty
        ? _ageOfLiftCtrl.text
        : _pWarranty.text;

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
      'elevator_type': elevatorTypeVal,
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
      'door_opening_size': _pDoorOpeningSize.text,
      'cabin_side_wall': _pCabinSideWallId ?? '',
      'landing_door': _pLandingDoorId ?? '',
      'cop': _pCopId ?? '',
      'lop': _pLopId ?? '',
      'wr': warrantyVal,
      'amc': amcTypeVal,
      'factory_price': _pFactoryPrice.text,
      'transportation': _pTransportation.text,
      'installation_charge': _pInstallation.text,
      'testing_commissioning': _pTesting.text,
      'consumables': _pConsumables.text,
      'additional_factory_charges': _pAdditionalFactory.text,
      'additional_amount': _pAdditional.text,
      'amc_amount': amcAmountVal,
      'quantity': _pQuantity.text.isNotEmpty ? _pQuantity.text : '1',
      'price': unitPriceVal,
      'tax_type': _pTaxType ?? '',
      'tax': _pTaxPercentage.text,
      'tax_amount': _pTaxAmount.text,
      'comp_profit': _pCompanyProfit.text,
      'comp_profit_amount': _pCompanyProfitAmount.text,
      'sales_commission': _pSalesCommission.text,
      'sales_commission_amount': _pSalesCommissionAmount.text,
      'sub_total': _pSubTotal.text,
      'grand_total': grandTotalVal,

      // AMC specific parameters
      'amc_type': amcTypeVal,
      'lift_brand': elevatorTypeVal,
      'age_of_lift': warrantyVal,
      'amc_subject': _pQuotationTitle.text,
      'amc_passenger_capacity': _pPassengerCapacity.text,
      'amc_price': amcAmountVal,

      // Quotation request parameters
      'sendQuoteRequest': _sendQuotation ? "1" : "0",
      'send_quotation': _sendQuotation ? "1" : "0",
      'create_quotation_request': _sendQuotation ? "1" : "0",
      'quote_request_sts': _sendQuotation ? "1" : "0",
      'request_title': _quotationTitleCtrl.text,
      'request_message': _quotationMessageCtrl.text,
      'quotation_type': _quotationType ?? '',
      'type': _quotationType ?? '',
      'assigned_to': _quotationAssignedTo ?? '',
      'quotation_assigned_to': _quotationAssignedTo ?? '',
    };
  }

  Future<void> _initializeData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.mobile) &&
        !connectivity.contains(ConnectivityResult.wifi)) {
      setState(() => isLoading = false);
      return;
    }

    contactPermission = await Common.getSharedPref("getContactPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    addLeadSource = await Common.getSharedPref("addLeadSource");
    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';

    final token = (widget.token != null && widget.token!.isNotEmpty)
        ? widget.token!
        : (await Common.getSharedPref("token") ?? "");

    try {
      userPermissions = await HttpService.userPermissionCheck(token);
    } catch (e) {
      log('Error fetching user permissions: $e');
    }

    commonDetails = await HttpService.addLeadCommonData(token);
    stateDetails = await HttpService.getState();
    productSectionModel = await HttpService.leadProductSection();
    leadSourceModel = await HttpService.getLeadSourceAddleads();
    configure = await HttpService.configure(token);

    leadDetails =
        await HttpService.leadDetails(token, widget.callMasterId);

    if (leadDetails?.data != null) {
      final data = leadDetails!.data!;
      _initEstimationFromData(data);

      clientNameCtrl.text = data.clientName ?? "";
      final cc = data.countryCode?.toString() ?? "";
      code = cc.isEmpty ? '91' : cc;
      final wc = data.whatsappNumberCountryCode?.toString() ?? "";
      whatsappCode = wc.isEmpty ? '91' : wc;
      contactNoCtrl.text = Common.trimCountryCode(
          mobileNumber: data.contactNumber1 ?? "", countryCode: code);
      whatsappNoCtrl.text = data.whatsaAppNumber ?? "";
      emailCtrl.text = data.emailId ?? "";
      costCtrl.text = data.cost?.toString() ?? "";
      addressCtrl.text = data.address ?? "";
      pinCodeCtrl.text = data.pinCode ?? "";
      remarkCtrl.text = data.remarks ?? "";
      final branchId = data.branchId?.toString();

      branch = (branchId == null || branchId.isEmpty || branchId == '0')
          ? null
          : branchId;

      leadType = data.leadCategory ?? 'Lead Category';
      leadTypeCtrl.text = leadType;
      leadTypeId = data.leadCategoryId?.toString() ?? '';

      if (commonDetails?.data.leadCategory != null) {
        if (leadTypeId.isNotEmpty) {
          try {
            final cat = commonDetails!.data.leadCategory.firstWhere(
              (c) => c.leadCategoryId.toString() == leadTypeId,
            );
            leadType = cat.leadCategory;
            leadTypeCtrl.text = cat.leadCategory;
          } catch (_) {}
        } else if (leadType != 'Lead Category' && leadType.isNotEmpty) {
          try {
            final cat = commonDetails!.data.leadCategory.firstWhere(
              (c) => c.leadCategory.toLowerCase() == leadType.toLowerCase(),
            );
            leadTypeId = cat.leadCategoryId.toString();
          } catch (_) {}
        }
      }

      leadSubType = data.leadSubCategory ?? 'Sub Category';
      leadSubTypeCtrl.text = leadSubType;
      leadSubTypeId = data.leadSubCategoryId?.toString() ?? '';
      assignStaff = data.staffName ?? 'Assign Staff';
      assignStaffCtrl.text = assignStaff;
      assignStaffId = data.assignedUserId?.toString() ?? '';
      priority = data.priority ?? 'Priority';
      priorityCtrl.text = priority;
      priorityId = data.priorityId?.toString() ?? '';
      leadSource = data.leadSource ?? 'Lead Source';
      leadSourceId = data.leadSourceId?.toString() ?? '';

      if (commonDetails?.data.leadSource != null) {
        for (var src in commonDetails!.data.leadSource) {
          if (src.leadSourceId.toString() == leadSourceId &&
              src.isRestricted == "Y") {
            leadSource = "${src.leadSource} (Restricted)";
            break;
          }
        }
      }
      leadSourceCtrl.text = leadSource;

      callResult = data.callResult ?? 'New';
      callResultId = data.callResultId?.toString() ?? '1';
      callResultCtrl.text = callResult;
      nextFollowupCtrl.text = data.nextFollowupDate ?? "";
      _fetchLeadExtraSettings(callResultId);

      final respId = (data.callResponseId != null && data.callResponseId!.isNotEmpty)
          ? data.callResponseId!
          : (data.rawJson?['call_response_id']?.toString() ?? '');
      final respName = (data.callResponse != null && data.callResponse!.isNotEmpty)
          ? data.callResponse!
          : (data.rawJson?['call_response']?.toString() ?? '');

      callResponseId = respId;
      if (respName.isNotEmpty && respName != 'Call Response') {
        callResponse = respName;
        callResponseCtrl.text = respName;
      }

      if (commonDetails?.data.callResponseStatus != null) {
        if (callResponseId.isNotEmpty) {
          try {
            final crs = commonDetails!.data.callResponseStatus.firstWhere(
              (c) => c.callResponseId.toString() == callResponseId,
            );
            callResponse = crs.callResponse.toString();
            callResponseCtrl.text = callResponse;
          } catch (_) {}
        } else if (callResponse != 'Call Response' && callResponse.isNotEmpty) {
          try {
            final crs = commonDetails!.data.callResponseStatus.firstWhere(
              (c) => c.callResponse.toLowerCase() == callResponse.toLowerCase(),
            );
            callResponseId = crs.callResponseId.toString();
          } catch (_) {}
        }
      }

      if (leadTypeId.isNotEmpty) {
        leadSubTypeList = await HttpService.leadSubType(leadTypeId);
      }
      if (pinCodeCtrl.text.length == 6) {
        _loadPostOffices(pinCodeCtrl.text, initial: true);
      }
      if (data.stateId != null && data.stateId!.isNotEmpty) {
        StateId = data.stateId;
        stateCtrl.text = data.stateName ?? "";
        _loadDistricts(StateId!, initial: true);
      }
      if (data.productsOnAdd != null && data.productsOnAdd!.isNotEmpty) {
        final productIds = data.productsOnAdd!.split(',');
        if (productSectionModel?.data != null) {
          _selectedProducts = productSectionModel!.data!
              .where((p) => productIds.any((id) => id.trim() == p.id))
              .toList();
        }
      }
      _updateTotalCost();
      final addonDet =
          await HttpService.listAddonDet(token, widget.callMasterId);
      if (addonDet?.data != null) {
        for (var field in addonDet!.data.additionalFields) {
          final ctrl =
              TextEditingController(text: field.value?.toString() ?? "");
          _additionalCtrls.add(ctrl);
        }
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadPostOffices(String pin, {bool initial = false}) async {
    setState(() => isPinLoading = true);
    final model = await HttpService.fetchPostOffice(pin);
    setState(() {
      isPinLoading = false;
      postalCodeModel = model;
      postOffices = model.postOffice ?? [];
      if (initial && leadDetails?.data?.postOffice != null) {
        final poName = leadDetails!.data!.postOffice!.toLowerCase();
        final matches = postOffices.where(
          (po) => po.name?.toLowerCase() == poName,
        );
        selectedPostOffice = matches.isNotEmpty ? matches.first : (postOffices.isNotEmpty ? postOffices.first : null);
      } else if (!initial) {
        selectedPostOffice = null;
      }
    });
  }

  Future<void> _loadDistricts(String sId, {bool initial = false}) async {
    if (!mounted) return;
    setState(() => isDistrictLoading = true);
    try {
      final result = await HttpService.getDistrict(sId);
      if (!mounted) return;
      final districts = result?.data ?? [];
      setState(() {
        districtList = districts;
        isDistrictLoading = false;

        if (initial && leadDetails?.data?.districtId != null) {
          final districtId = leadDetails!.data!.districtId;
          final matchingDistrict = districtList.where(
            (d) => d.id == districtId,
          );
          if (matchingDistrict.isNotEmpty) {
            final district = matchingDistrict.first;
            DistrictId = district.id;
            districtCtrl.text = district.name;
          } else {
            DistrictId = null;
            districtCtrl.clear();
          }
        } else if (!initial) {
          DistrictId = null;
          districtCtrl.clear();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        districtList = [];
        DistrictId = null;
        districtCtrl.clear();
        isDistrictLoading = false;
      });
      log("Error loading districts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', width: 150))
          : leadDetails == null || commonDetails == null || configure == null
              ? _buildNoNetworkView()
              : configure!.data!.isExpired == true
                  ? _buildExpiredView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Lead',
          style: TextStyle(color: Colors.white, fontSize: 18)),
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
            DropdownMenuItem(value: "Amc", child: Text("Amc")),
            DropdownMenuItem(value: "General", child: Text("General")),
            DropdownMenuItem(value: "Repairing", child: Text("Repairing")),
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
          Image.asset('assets/icons/noNetwork.jpg', width: 200, height: 200),
          const Text('No Network Found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ElevatedButton(
              onPressed: _initializeData, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/main/packageimage.png', height: 160),
          const Text('Package Expired!',
              style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('UPGRADE')),
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
                if (callResultId != '1') _buildCallResponseField(),
              ],
            ),
            if (callResultId == '16' ||
                callResultId == '17' ||
                callResult == 'Estimation & Pricing' ||
                callResult == 'Quotation Request' ||
                callResult.toLowerCase().contains('estimation') ||
                callResult.toLowerCase().contains('quotation') ||
                leadTypeId == '11' ||
                leadType.trim().toUpperCase() == 'AMC') ...[
              const SizedBox(height: 12),
              if (leadTypeId == '11' ||
                  leadType.trim().toUpperCase() == 'AMC') ...[
                _buildAMCSection(),
              ] else if (leadTypeId == '12' ||
                  leadType.trim().toUpperCase() == 'REPAIR' ||
                  leadType.trim().toLowerCase() == 'repairing') ...[
                EstimationPricingCard(
                  data: leadDetails?.data,
                  permissions: userPermissions,
                  showEstimation: false,
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
                  doorOpeningSizeCtrl: _pDoorOpeningSize,
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
              ] else ...[
                EstimationPricingCard(
                  data: leadDetails?.data,
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
                  doorOpeningSizeCtrl: _pDoorOpeningSize,
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
                // CheckboxListTile(
                //   contentPadding: EdgeInsets.zero,
                //   title: const Text(
                //     'Create Quotation Request',
                //     style: TextStyle(
                //       fontSize: 14,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                //   value: _sendQuotation,
                //   onChanged: (value) {
                //     setState(() {
                //       _sendQuotation = value ?? false;
                //     });
                //   },
                //   controlAffinity: ListTileControlAffinity.leading,
                // ),
                // if (_sendQuotation) _buildQuotationRequestForm(),
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
                  ..._buildAdditionalFieldsUI(),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: _buildSubmitButton()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAMCSection() {
    return _buildSectionCard(
      title: 'AMC',
      icon: Icons.shield_outlined,
      children: [
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _amcTypeSelected,
                decoration: _inputDecoration('AMC Type *', null,
                    hintText: 'Select AMC Type'),
                hint: const Text(
                  'Select AMC Type',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Comprehensive AMC',
                      child: Text('Comprehensive AMC')),
                  DropdownMenuItem(
                      value: 'Non Comprehensive AMC',
                      child: Text('Non Comprehensive AMC')),
                ],
                onChanged: (val) {
                  setState(() {
                    _amcTypeSelected = val;
                    _amcTypeCtrl.text = val ?? '';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _liftBrandCtrl,
                decoration: _inputDecoration('Lift Brand *', null,
                    hintText: 'Enter Lift Brand'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _ageOfLiftCtrl,
                decoration: _inputDecoration('Age of Lift *', null,
                    hintText: 'Enter Age of Lift'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _pQuotationTitle,
                decoration: _inputDecoration('Subject *', null,
                    hintText: 'Enter Subject'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _pPassengerCapacity,
                decoration: _inputDecoration('Passenger Capacity/KG *', null,
                    hintText: 'Enter Passenger Capacity/KG'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _amcPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Price *', null,
                    hintText: 'Enter Price'),
              ),
            ),
          ],
        ),
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

  Widget _buildBranchField() {
    return DropdownButtonFormField<String>(
      value: branch,
      decoration: _inputDecoration('Select Branch', Icons.business),
      items: commonDetails!.data.branch
          .map((b) => DropdownMenuItem(
              value: b.branchId.toString(), child: Text(b.branchName)))
          .toList(),
      onChanged: (v) => setState(() => branch = v),
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: clientNameCtrl,
            decoration: _inputDecoration('Customer Name *', Icons.person),
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
      decoration: _inputDecoration('Contact Number *', Icons.phone).copyWith(
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
              children: [
                Text("+$code"),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ),
      validator: (v) => (v!.isEmpty)
          ? 'Required'
          : (code == '91' && v.length != 10)
              ? '10 digits'
              : null,
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
                const Icon(Icons.arrow_drop_down),
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
            return 'Invalid';
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
          controller: assignStaffCtrl,
          decoration: _inputDecoration('Assign Staff', Icons.person),
        ),
      ),
    );
  }

  Widget _buildStatusField() {
    final statusList = commonDetails?.data.callResult ?? [];
    if (statusList.isEmpty) {
      return GestureDetector(
        onTap: () => _showCallResultDialog(),
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(text: callResult),
            decoration: _inputDecoration(
                'Stages', Icons.arrow_drop_down_circle_outlined),
          ),
        ),
      );
    }

    final selectedValue = statusList
            .any((cr) => cr.callResultId.toString() == callResultId)
        ? callResultId
        : statusList
                .any((cr) => cr.callResult.toLowerCase() == callResult.toLowerCase())
            ? statusList
                .firstWhere(
                    (cr) => cr.callResult.toLowerCase() == callResult.toLowerCase())
                .callResultId
                .toString()
            : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: _inputDecoration(
          'Stages *', Icons.arrow_drop_down_circle_outlined),
      hint: const Text(
        'Select Stage',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
      items: statusList.map((cr) {
        return DropdownMenuItem<String>(
          value: cr.callResultId.toString(),
          child: Text(cr.callResult),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          final cr = statusList.firstWhere(
            (c) => c.callResultId.toString() == value,
          );
          setState(() {
            final bool stageChanged = callResultId != value;
            callResult = cr.callResult;
            callResultCtrl.text = callResult;
            callResultId = value;
            if (stageChanged && value == '1') {
              callResponse = 'Call Response';
              callResponseId = '';
              callResponseCtrl.clear();
            }
            if (callResultId != '2') nextFollowupCtrl.clear();
            _fetchLeadExtraSettings(callResultId);
            if (callResultId == '16' ||
                callResult == 'Estimation & Pricing' ||
                callResult.toLowerCase().contains('estimation')) {
              _syncEstimationDefaults();
            }
          });
        }
      },
      validator: (value) {
        if (callResultId.isEmpty) {
          return 'Please select Stage';
        }
        return null;
      },
    );
  }

  Widget _buildCallResponseField() {
    return GestureDetector(
      onTap: () => _showCallResponseDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResponseCtrl,
          decoration: _inputDecoration('Call Response *', Icons.add_call),
          validator: (value) {
            if (callResultId != '1' &&
                (value == null ||
                    value.trim().isEmpty ||
                    callResponseId.isEmpty)) {
              return 'Please select Call Response';
            }
            return null;
          },
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
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null && mounted) {
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

  Future<void> _showCallResultDialog() async {
    if (commonDetails?.data == null) {
      Common.toastMessaage("Common details not loaded", Colors.orange);
      return;
    }
    final searchCtrl = TextEditingController();
    var filtered = List.from(commonDetails!.data.callResult);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Select Stage'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 350,
            child: Column(
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search Stage...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setDialogState(() {
                    filtered = commonDetails!.data.callResult
                        .where((cr) => cr.callResult
                            .toLowerCase()
                            .contains(v.toLowerCase()))
                        .toList();
                  }),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final cr = filtered[i];
                      return ListTile(
                        title: Text(cr.callResult),
                        onTap: () {
                          setState(() {
                            final bool stageChanged =
                                callResultId != cr.callResultId.toString();
                            callResult = cr.callResult;
                            callResultId = cr.callResultId.toString();
                            callResultCtrl.text = callResult;
                            if (stageChanged) {
                              callResponse = 'Call Response';
                              callResponseId = '';
                              callResponseCtrl.clear();
                            }
                            _fetchLeadExtraSettings(callResultId);
                            if (callResultId == '16' ||
                                callResult == 'Estimation & Pricing' ||
                                callResult.toLowerCase().contains('estimation')) {
                              _syncEstimationDefaults();
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
        ),
      ),
    );
  }

  Future<void> _showCallResponseDialog() async {
    if (commonDetails?.data == null) {
      Common.toastMessaage("Common details not loaded", Colors.orange);
      return;
    }
    final searchCtrl = TextEditingController();
    var filtered = List.from(commonDetails!.data.callResponseStatus);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Select Call Response'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setDialogState(() {
                    filtered = commonDetails!.data.callResponseStatus
                        .where((crs) => crs.callResponse
                            .toString()
                            .toLowerCase()
                            .contains(v.toLowerCase()))
                        .toList();
                  }),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final crs = filtered[i];
                      return ListTile(
                        title: Text(crs.callResponse.toString()),
                        onTap: () {
                          setState(() {
                            callResponse = crs.callResponse.toString();
                            callResponseId = crs.callResponseId.toString();
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
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return "";
    final parts = date.split('-');
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  Widget _buildLeadCategoryField() {
    final categoryList = commonDetails?.data.leadCategory ?? [];
    if (categoryList.isEmpty) {
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
                              leadSubType = 'Sub Category';
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

    final selectedValue = categoryList
            .any((c) => c.leadCategoryId.toString() == leadTypeId)
        ? leadTypeId
        : categoryList.any(
                (c) => c.leadCategory.toLowerCase() == leadType.toLowerCase())
            ? categoryList
                .firstWhere(
                    (c) => c.leadCategory.toLowerCase() == leadType.toLowerCase())
                .leadCategoryId
                .toString()
            : null;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: _inputDecoration(
                'Lead Category *', Icons.arrow_drop_down_circle_outlined),
            hint: const Text(
              'Select Lead Category',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            items: categoryList.map((cat) {
              return DropdownMenuItem<String>(
                value: cat.leadCategoryId.toString(),
                child: Text(cat.leadCategory),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                final cat = categoryList.firstWhere(
                  (c) => c.leadCategoryId.toString() == value,
                );
                leadSubTypeList = await HttpService.leadSubType(value);
                setState(() {
                  leadTypeId = value;
                  leadType = cat.leadCategory;
                  leadTypeCtrl.text = cat.leadCategory;
                  leadSubType = 'Sub Category';
                  leadSubTypeCtrl.text = leadSubType;
                  leadSubTypeId = '';
                });
              }
            },
            validator: (value) {
              if (leadTypeId.isEmpty) {
                return 'Please select Lead Category';
              }
              return null;
            },
          ),
        ),
        if (createLeadCategory == 'true') ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubCategoryField() => GestureDetector(
      onTap: () => _showSubCategoryDialog(),
      child: AbsorbPointer(
          child: TextFormField(
              controller: leadSubTypeCtrl,
              decoration: _inputDecoration(
                  'Sub Category', Icons.subdirectory_arrow_right))));

  Widget _buildLeadSourceField() =>
      Stack(alignment: Alignment.centerRight, children: [
        GestureDetector(
            onTap: () => _showSourceDialog(),
            child: AbsorbPointer(
                child: TextFormField(
                    controller: leadSourceCtrl,
                    decoration:
                        _inputDecoration('Lead Source', Icons.source)))),
        if (addLeadSource == 'true')
          Positioned(
              right: 5,
              child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showAddSourceDialog())),
      ]);

  Widget _buildPriorityField() => GestureDetector(
      onTap: () => _showPriorityDialog(),
      child: AbsorbPointer(
          child: TextFormField(
              controller: priorityCtrl,
              decoration: _inputDecoration('Priority', Icons.priority_high))));

  Widget _buildAddressField() => TextFormField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Address', Icons.home));

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: pinCodeCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('PIN Code', Icons.pin_drop).copyWith(
        suffixIcon: isPinLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : null,
      ),
      onChanged: (v) {
        if (v.length == 6) {
          _loadPostOffices(v);
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
        items: postOffices
            .map(
                (po) => DropdownMenuItem(value: po, child: Text(po.name ?? '')))
            .toList(),
        onChanged: (v) => setState(() => selectedPostOffice = v));
  }

  Widget _buildLocationFields() {
    return Column(children: [
      GestureDetector(
          onTap: () => _showStateDialog(),
          child: AbsorbPointer(
              child: TextFormField(
                  controller: stateCtrl,
                  decoration: _inputDecoration('State', Icons.map)))),
      const SizedBox(height: 12),
      if (isDistrictLoading)
        const Center(child: CircularProgressIndicator())
      else if (districtList.isNotEmpty)
        DropdownButtonFormField<DistrictList>(
          value: districtList.where((d) => d.id == DistrictId).isNotEmpty
              ? districtList.firstWhere((d) => d.id == DistrictId)
              : null,
          decoration: _inputDecoration('District', Icons.location_city),
          hint: const Text("Select District"),
          items: districtList
              .map(
                (d) => DropdownMenuItem<DistrictList>(
                  value: d,
                  child: Text(d.name),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              DistrictId = v?.id;
              districtCtrl.text = v?.name ?? '';
            });
          },
        ),
    ]);
  }

  Widget _buildRemarksField() => TextFormField(
      controller: remarkCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Remarks', Icons.notes));

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Products",
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showProductSelectionDialog(),
                child: AbsorbPointer(
                  child: TextFormField(
                    key: ValueKey(_selectedProducts.length),
                    initialValue: _selectedProducts.isEmpty
                        ? ''
                        : "${_selectedProducts.length} Product(s) Selected",
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
                            onTap: () => setState(() {
                              _selectedProducts.remove(p);
                              _updateTotalCost();
                            }),
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

  void _updateTotalCost() {
    double total = 0;
    for (var p in _selectedProducts) {
      String amountStr = (p.totalAmount ?? '0').replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    costCtrl.text = total.toStringAsFixed(2);
  }

  List<Widget> _buildAdditionalFieldsUI() {
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      if (_additionalCtrls.length <= i) {
        _additionalCtrls.add(TextEditingController());
      }
      final field = commonDetails!.data.additionalFields[i];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _additionalCtrls[i],
          decoration: _inputDecoration(field.fieldName, Icons.add_box_outlined),
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: _submitLead,
      child: const Text('Update Lead',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String? label, IconData? icon,
      {bool isDense = false, String? hintText}) {
    return InputDecoration(
      isDense: isDense,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
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

  void _showStaffDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(commonDetails!.data.staff);
        return StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Assign Staff'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(hintText: "Search"),
                    onChanged: (v) => setS(() => list = commonDetails!
                        .data.staff
                        .where((s) => s.staffName
                            .toString()
                            .toLowerCase()
                            .contains(v.toLowerCase()))
                        .toList()),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (c, i) {
                        final staff = list[i];
                        return ListTile(
                          title: Text(staff.staffName!),
                          onTap: () {
                            setState(() {
                              assignStaff = staff.staffName!;
                              assignStaffCtrl.text = assignStaff;
                              assignStaffId = staff.userId.toString();
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
          ),
        );
      },
    );
  }

  void _showCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(commonDetails!.data.leadCategory);
        return StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Lead Category'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(hintText: "Search"),
                    onChanged: (v) => setS(() => list = commonDetails!
                        .data.leadCategory
                        .where((cat) => cat.leadCategory
                            .toLowerCase()
                            .contains(v.toLowerCase()))
                        .toList()),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (c, i) => ListTile(
                        title: Text(list[i].leadCategory),
                        onTap: () async {
                          setState(() {
                            leadType = list[i].leadCategory;
                            leadTypeCtrl.text = leadType;
                            leadTypeId = list[i].leadCategoryId.toString();
                            leadSubType = 'Sub Category';
                            leadSubTypeCtrl.text = leadSubType;
                            leadSubTypeId = '';
                          });
                          Navigator.pop(context);
                          leadSubTypeList =
                              await HttpService.leadSubType(leadTypeId);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSubCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sub Category'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: leadSubTypeList?.data?.length ?? 0,
            itemBuilder: (c, i) => ListTile(
              title: Text(leadSubTypeList!.data![i].leadSubCategory!),
              onTap: () {
                setState(() {
                  leadSubType = leadSubTypeList!.data![i].leadSubCategory!;
                  leadSubTypeCtrl.text = leadSubType;
                  leadSubTypeId =
                      leadSubTypeList!.data![i].leadSubCategoryId.toString();
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List<LeadSource>.from(commonDetails!.data.leadSource);
        return StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Lead Source'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(hintText: "Search"),
                    onChanged: (v) => setS(() => list = commonDetails!
                        .data.leadSource
                        .where((src) => src.leadSource
                            .toLowerCase()
                            .contains(v.toLowerCase()))
                        .toList()),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (c, i) {
                        final src = list[i];
                        final bool isRestricted = src.isRestricted == "Y";
                        return ListTile(
                          title: Text(
                            isRestricted
                                ? "${src.leadSource} (Restricted)"
                                : src.leadSource,
                            style: TextStyle(
                              color: isRestricted
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                          enabled: !isRestricted,
                          onTap: isRestricted
                              ? null
                              : () {
                                  setState(() {
                                    leadSource = src.leadSource;
                                    leadSourceCtrl.text = leadSource;
                                    leadSourceId = src.leadSourceId.toString();
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
          ),
        );
      },
    );
  }

  void _showPriorityDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: commonDetails!.data.priority
              .map((p) => ListTile(
                    title: Text(p.priority),
                    onTap: () {
                      setState(() {
                        priority = p.priority;
                        priorityCtrl.text = priority;
                        priorityId = p.priorityId.toString();
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showStateDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(stateDetails!.data);
        return StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Select State'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(hintText: "Search"),
                    onChanged: (v) => setS(() => list = stateDetails!.data
                        .where((s) =>
                            s.name.toLowerCase().contains(v.toLowerCase()))
                        .toList()),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (c, i) => ListTile(
                        title: Text(list[i].name),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            stateCtrl.text = list[i].name;
                            StateId = list[i].id;
                          });
                          _loadDistricts(StateId!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProductSelectionDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) {
        List<LeadProduct> filteredProducts =
            List.from(productSectionModel?.data ?? []);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Select Products"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "Search Products",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        setDialogState(() {
                          filteredProducts = productSectionModel!.data!
                              .where((p) => (p.productName ?? "")
                                  .toLowerCase()
                                  .contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (c, i) {
                          final p = filteredProducts[i];
                          final isSelected =
                              _selectedProducts.any((sp) => sp.id == p.id);
                          return CheckboxListTile(
                            title: Text(p.productName ?? ""),
                            subtitle: Text("₹${p.totalAmount}"),
                            value: isSelected,
                            onChanged: (v) {
                              setState(() {
                                if (v!) {
                                  _selectedProducts.add(p);
                                } else {
                                  _selectedProducts
                                      .removeWhere((sp) => sp.id == p.id);
                                }
                                _updateTotalCost();
                              });
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
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadCategoryDialog(
        onSubmit: (name, cost, sub) async {
          final response = await HttpService.postLeadCategory(name, cost, sub);
          if (response?.status ?? false) {
            commonDetails =
                await HttpService.addLeadCommonData(widget.token);
            if (mounted) setState(() {});
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed')),
              );
            }
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadSourceDialog(
        onSubmit: (name) async {
          final response = await HttpService.postLeadSource(name);
          if (response?.status ?? false) {
            commonDetails =
                await HttpService.addLeadCommonData(widget.token);
            if (mounted) {
              setState(() {});
              Navigator.pop(context);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String number =
            contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
        if (number.startsWith('+')) {
          number = number.substring(number.length - 10);
        } else if (number.length > 10) {
          number = number.substring(number.length - 10);
        }
        setState(() {
          contactNoCtrl.text = number;
          whatsappNoCtrl.text = number;
          clientNameCtrl.text = contact.displayName;
        });
      }
    } else {
      Common.toastMessaage('Permission denied', Colors.red);
    }
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

  Future<void> _submitLead() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }

    bool nextFollowUpRequired =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (nextFollowUpRequired && nextFollowupCtrl.text.isEmpty) {
      Common.toastMessaage('Select Next Followup Date', Colors.red);
      return;
    }

    if (callResultId != '1' && callResponseId.isEmpty) {
      Common.toastMessaage('Select Call Response', Colors.red);
      return;
    }

    if (_sendQuotation) {
      if (_quotationTitleCtrl.text.trim().isEmpty) {
        Common.toastMessaage('Request Title is required', Colors.red);
        return;
      }
      if (_quotationMessageCtrl.text.trim().isEmpty) {
        Common.toastMessaage('Request Message is required', Colors.red);
        return;
      }
    }

    Common.showProgressDialog(context, "Updating...");

    _additionalValues.clear();
    for (int i = 0; i < commonDetails!.data.additionalFields.length; i++) {
      _additionalValues.add({
        "id": commonDetails!.data.additionalFields[i].id,
        "name": commonDetails!.data.additionalFields[i].fieldName,
        "value": _additionalCtrls.length > i ? _additionalCtrls[i].text : ""
      });
    }

    final isEstimationStage = callResultId == '16' ||
        callResultId == '17' ||
        callResult == 'Estimation & Pricing' ||
        callResult == 'Quotation Request' ||
        callResult.toLowerCase().contains('estimation') ||
        callResult.toLowerCase().contains('quotation') ||
        leadTypeId == '11' ||
        leadType.trim().toUpperCase() == 'AMC' ||
        _sendQuotation;
    final pricingBody = isEstimationStage ? _buildPricingBody() : null;

    final res = await HttpService.editLeads(
      widget.token,
      widget.callMasterId,
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
      selectedPostOffice?.name ?? "",
      remarkCtrl.text,
      callResultId,
      callResponseId,
      nextFollowupCtrl.text,
      checked ? "1" : "0",
      timeBeforeCtrl.text,
      _additionalValues,
      code,
      leadSourceId,
      stateId: StateId,
      districtId: DistrictId,
      products: _selectedProducts.map((p) => p.id).join(','),
      whatsappNumber: whatsappNoCtrl.text,
      whatsappnumber_country_code: whatsappCode,
      email: emailCtrl.text,
      pricingData: pricingBody,
      sendQuotation: _sendQuotation,
      requestTitle: _quotationTitleCtrl.text.trim(),
      requestMessage: _quotationMessageCtrl.text.trim(),
      quotationType: _quotationType,
      quotationAssignedTo: _quotationAssignedTo,
    );

    if (!mounted) return;
    Navigator.pop(context);
    if (res?.status == true) {
      Common.toastMessaage(res!.message, Colors.green);
      if (mounted) Navigator.pop(context, true);
    } else {
      Common.toastMessaage(res?.message ?? "Update failed", Colors.red);
    }
  }
}
