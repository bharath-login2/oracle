import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/common.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/callResultResonModel.dart';
import '../../models/lead_management/editLeadFollowupModel.dart';
import '../../models/lead_management/followupDetailsModel.dart';
import '../../models/lead_management/leadSubTypeModel.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/userPermissionModel.dart';
import '../../service/service.dart';
import '../../models/lead_management/leadExtraSettings.dart';
import 'package:login2/models/expense/staffListModel.dart' as expense;
import 'package:login2/widgets/estimation_pricing_card.dart';
import 'dart:developer';
import 'package:login2/screens/product_mannagement/add_products.dart';

// ignore: must_be_immutable
class EditFollowup extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String callMasterId;
  String callFollowupId;

  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  int? scrollToIndex;

  EditFollowup(this.token, this.editLead, this.deleteLead, this.cloudCall,
      this.callMasterId, this.callFollowupId,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrollToIndex});

  @override
  State<EditFollowup> createState() => _EditFollowupState();
}

class _EditFollowupState extends State<EditFollowup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
  CallResultResonModel? callResultReason;

  // Form Fields
  String callResult = 'New';
  String callResultId = '1';
  String callResponse = 'Call Status';
  String callResponseId = '';
  String leadType = 'Lead Category';
  String leadTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String leadSubTypeId = '';
  String callResultReasonName = 'Tag';
  String callResultReasonId = '';

  final TextEditingController cost = TextEditingController();
  final TextEditingController remarks = TextEditingController();
  final TextEditingController calledDate1 = TextEditingController();
  final TextEditingController nextFollowupDate1 = TextEditingController();
  final TextEditingController leadTypeVal = TextEditingController();
  final TextEditingController leadSubTypeVal = TextEditingController();
  final TextEditingController callResultVal = TextEditingController();
  final TextEditingController callResponseVal = TextEditingController();
  final TextEditingController callReasonVal = TextEditingController();
  final TextEditingController whatsappLead = TextEditingController();
  final TextEditingController emailLead = TextEditingController();
  LeadSettings? leadSettings;
  bool checked = false;
  final TextEditingController timeBefore = TextEditingController(text: '10');
  bool isLoadingSettings = false;

  // Estimation & AMC Data
  LeadDeatailsModel? estimationDetails;
  UserPermissionModel? userPermissions;

  // AMC section controllers & state
  String? _amcTypeSelected;
  final TextEditingController _amcTypeCtrl = TextEditingController();
  final TextEditingController _liftBrandCtrl = TextEditingController();
  final TextEditingController _ageOfLiftCtrl = TextEditingController();
  final TextEditingController _amcPriceCtrl = TextEditingController();

  // Estimation & Pricing controllers
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
  String? _pLiftTypeId;
  String? _pOpeningId;
  String? _pDoorOpeningId;
  String? _pCabinSideWallId;
  String? _pLandingDoorId;
  String? _pCopId;
  String? _pLopId;
  final TextEditingController _pFactoryPrice = TextEditingController();
  final TextEditingController _pTransportation = TextEditingController();
  final TextEditingController _pInstallation = TextEditingController();
  final TextEditingController _pTesting = TextEditingController();
  final TextEditingController _pConsumables = TextEditingController();
  final TextEditingController _pAdditionalFactory = TextEditingController();
  final TextEditingController _pAdditional = TextEditingController();
  final TextEditingController _pAmcAmount = TextEditingController();
  final TextEditingController _pQuantity = TextEditingController();
  final TextEditingController _pUnitPrice = TextEditingController();
  final TextEditingController _pCompanyProfit = TextEditingController();
  final TextEditingController _pCompanyProfitAmount = TextEditingController();
  final TextEditingController _pSalesCommission = TextEditingController();
  final TextEditingController _pSalesCommissionAmount = TextEditingController();
  final TextEditingController _pSubTotal = TextEditingController();
  final TextEditingController _pTaxPercentage = TextEditingController();
  final TextEditingController _pTaxAmount = TextEditingController();
  final TextEditingController _pTotalSalePrice = TextEditingController();
  String? _pTaxType;

  // Quotation Request fields
  final TextEditingController _quotationTitleCtrl =
      TextEditingController(text: "Quotation Request");
  final TextEditingController _quotationMessageCtrl = TextEditingController(
    text: "Kindly prepare and send the quotation for this lead.",
  );
  String? _quotationType = "General";
  String? _quotationAssignedTo;
  bool _sendQuotation = false;

  List<expense.Staff> quotationStaffList = [];
  bool isQuotationStaffLoading = false;

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

  FollowupDetailsModel? followupDetails;
  LeadProductSectionModel? productSectionModel;
  LeadDeatailsModel? leadDetails;
  List<LeadProduct> _selectedProducts = [];
  String? _expandedProductId;
  final Map<String, String> _productDescriptions = {};
  final Map<String, bool> _descriptionLoading = {};

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

  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];

  bool? result = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    cost.dispose();
    remarks.dispose();
    calledDate1.dispose();
    nextFollowupDate1.dispose();
    leadTypeVal.dispose();
    leadSubTypeVal.dispose();
    callResultVal.dispose();
    callResponseVal.dispose();
    callReasonVal.dispose();
    whatsappLead.dispose();
    emailLead.dispose();
    timeBefore.dispose();
    _amcTypeCtrl.dispose();
    _liftBrandCtrl.dispose();
    _ageOfLiftCtrl.dispose();
    _amcPriceCtrl.dispose();
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

    for (var ctrl in _additionalCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String getYmdFromDmy(String dmy) {
    if (dmy.isEmpty) return dmy;
    final split = dmy.split("-");
    return "${split[2]}-${split[1]}-${split[0]}";
  }

  Future<void> _loadQuotationStaffs() async {
    setState(() => isQuotationStaffLoading = true);
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
      if (mounted) setState(() => isQuotationStaffLoading = false);
    }
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() => result = true);
      } else {
        setState(() => result = false);
      }
    } else {
      setState(() => result = false);
    }

    if (result == false) {
      setState(() => isLoading = false);
      return;
    }

    try {
      commonDetails = await HttpService.addLeadCommonData(widget.token);
      productSectionModel = await HttpService.leadProductSection();
      leadDetails =
          await HttpService.leadDetails(widget.token, widget.callMasterId);
      estimationDetails = leadDetails;
      userPermissions = await HttpService.userPermissionCheck(widget.token);
      followupDetails = await HttpService.followupDetails(
          widget.token, widget.callFollowupId);

      _loadQuotationStaffs();

      if (estimationDetails?.data != null) {
        _initEstimationFromData(estimationDetails!.data);
      }

      if (followupDetails != null) {
        if (followupDetails!.data!.leadCategoryId.toString().isNotEmpty) {
          leadSubTypeList = await HttpService.leadSubType(
              followupDetails!.data!.leadCategoryId.toString());
        }

        _initializeAdditionalFields();
        _populateFormData();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
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
      }
    }
    if (_pPhone.text.isEmpty) {
      if (data.contactNumber1 != null && data.contactNumber1!.isNotEmpty) {
        _pPhone.text = data.contactNumber1 ?? '';
      }
    }
    if (_pLocation.text.isEmpty) {
      if (data.location != null && data.location!.isNotEmpty) {
        _pLocation.text = data.location ?? '';
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
    if (_pDoorOpeningSize.text.isEmpty &&
        data.doorOpeningSize != null &&
        data.doorOpeningSize!.isNotEmpty) {
      _pDoorOpeningSize.text = data.doorOpeningSize ?? '';
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
    final elevatorTypeVal = _liftBrandCtrl.text.trim().isNotEmpty
        ? _liftBrandCtrl.text
        : _pElevatorType.text;
    final amcTypeVal = _pAmc.text.trim().isNotEmpty
        ? _pAmc.text
        : (_amcTypeCtrl.text.trim().isNotEmpty ? _amcTypeCtrl.text : _pAmc.text);
    final amcAmountVal = _pAmcAmount.text.trim().isNotEmpty
        ? _pAmcAmount.text
        : (_amcPriceCtrl.text.trim().isNotEmpty ? _amcPriceCtrl.text : _pAmcAmount.text);
    final unitPriceVal = _pUnitPrice.text.trim().isNotEmpty
        ? _pUnitPrice.text
        : (_amcPriceCtrl.text.trim().isNotEmpty ? _amcPriceCtrl.text : _pUnitPrice.text);
    final grandTotalVal = _pTotalSalePrice.text.trim().isNotEmpty
        ? _pTotalSalePrice.text
        : (_amcPriceCtrl.text.trim().isNotEmpty ? _amcPriceCtrl.text : _pTotalSalePrice.text);
    final warrantyVal = _pWarranty.text.trim().isNotEmpty
        ? _pWarranty.text
        : (_ageOfLiftCtrl.text.trim().isNotEmpty ? _ageOfLiftCtrl.text : _pWarranty.text);

    return <String, dynamic>{
      'quotation_title': _pQuotationTitle.text,
      'quotation': _pQuotation.text,
      'client_name': _pClientName.text,
      'phone': _pPhone.text,
      'location': _pLocation.text,
      'lift_brand': elevatorTypeVal,
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
      'wr': _pWarranty.text.trim().isNotEmpty ? _pWarranty.text.trim() : warrantyVal,
      'warranty': _pWarranty.text.trim().isNotEmpty ? _pWarranty.text.trim() : warrantyVal,
      'amc': _pAmc.text.trim().isNotEmpty ? _pAmc.text.trim() : amcTypeVal,
      'amc_year': _pAmc.text.trim().isNotEmpty ? _pAmc.text.trim() : amcTypeVal,
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
    };
  }

  void _initializeAdditionalFields() {
    if (commonDetails?.data.additionalFields != null) {
      if (_additionalCtrls.length !=
          commonDetails!.data.additionalFields.length) {
        for (var ctrl in _additionalCtrls) {
          ctrl.dispose();
        }
        _additionalCtrls.clear();
        for (int i = 0; i < commonDetails!.data.additionalFields.length; i++) {
          String initialValue = "";
          if (followupDetails?.data?.additionalFields != null) {
            final fieldId = commonDetails!.data.additionalFields[i].id;
            final existing = followupDetails!.data!.additionalFields!
                .where((f) => f.id == fieldId)
                .toList();
            if (existing.isNotEmpty) {
              initialValue = existing.first.value ?? "";
            }
          }
          _additionalCtrls.add(TextEditingController(text: initialValue));
        }
      }
    }
  }

  List<Widget> _buildAdditionalFieldsUI() {
    if (commonDetails == null ||
        commonDetails!.data.additionalFields.isEmpty ||
        _additionalCtrls.length < commonDetails!.data.additionalFields.length) {
      return [];
    }
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _additionalCtrls[i],
          decoration: InputDecoration(
            labelText: commonDetails!.data.additionalFields[i].fieldName,
            prefixIcon: const Icon(Icons.edit_note),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    });
  }

  void _populateFormData() {
    setState(() {
      callResult = followupDetails!.data!.callResult.toString();
      callResultId = followupDetails!.data!.callResultId.toString();
      calledDate1.text = DateFormat('dd-MM-yyyy hh:mm a')
          .format(DateTime.parse(followupDetails!.data!.calledDate.toString()));
      if (followupDetails?.data?.followupDate != null &&
          !followupDetails!.data!.followupDate!.toString().contains("0001")) {
        nextFollowupDate1.text = DateFormat('dd-MM-yyyy hh:mm a').format(
            DateTime.parse(followupDetails!.data!.followupDate.toString()));
      } else {
        nextFollowupDate1.text = "";
      }
      leadType = followupDetails!.data!.leadCategory.toString();
      leadTypeId = followupDetails!.data!.leadCategoryId.toString();
      cost.text = followupDetails!.data!.cost.toString();
      remarks.text = followupDetails!.data!.remarks.toString();
      leadSubType = followupDetails!.data!.leadSubCategory.toString();
      leadSubTypeId = followupDetails!.data!.leadSubCategoryId.toString();
      leadTypeVal.text = followupDetails?.data?.leadCategory?.toString() ?? "";
      leadSubTypeVal.text = followupDetails!.data!.leadSubCategory.toString();
      callResultVal.text = followupDetails!.data!.callResult.toString();
      callResponse = followupDetails!.data!.callResponse.toString();
      callResponseId = followupDetails!.data!.callResponseId.toString();
      callResponseVal.text = followupDetails!.data!.callResponse.toString();

      callResultReasonName = followupDetails!.data!.reason.toString();
      callResultReasonId = followupDetails!.data!.reasonId.toString();
      callReasonVal.text = followupDetails!.data!.reason.toString();

      final fd = followupDetails?.data;
      final ld = leadDetails?.data;

      // Populate AMC section fields
      final amcVal = (fd?.amcType != null && fd!.amcType!.isNotEmpty)
          ? fd.amcType
          : ((fd?.amc != null && fd!.amc!.isNotEmpty)
              ? fd.amc
              : ld?.amc);
      if (amcVal != null && amcVal.isNotEmpty) {
        _amcTypeSelected = amcVal;
        _amcTypeCtrl.text = amcVal;
      }

      final brandVal = (fd?.liftBrand != null && fd!.liftBrand!.isNotEmpty)
          ? fd.liftBrand
          : ((fd?.elevatorType != null && fd!.elevatorType!.isNotEmpty)
              ? fd.elevatorType
              : ld?.elevatorType);
      if (brandVal != null && brandVal.isNotEmpty) {
        _liftBrandCtrl.text = brandVal;
      }

      final ageVal = (fd?.ageOfLift != null && fd!.ageOfLift!.isNotEmpty)
          ? fd.ageOfLift
          : ((fd?.wr != null && fd!.wr!.isNotEmpty)
              ? fd.wr
              : ld?.warranty);
      if (ageVal != null && ageVal.isNotEmpty) {
        _ageOfLiftCtrl.text = ageVal;
      }

      final subjectVal = (fd?.subject != null && fd!.subject!.isNotEmpty)
          ? fd.subject
          : ((fd?.quotationTitle != null && fd!.quotationTitle!.isNotEmpty)
              ? fd.quotationTitle
              : ld?.quotationTitle);
      if (subjectVal != null && subjectVal.isNotEmpty) {
        _pQuotationTitle.text = subjectVal;
      }

      final passCapVal = (fd?.passengerCapacity != null && fd!.passengerCapacity!.isNotEmpty)
          ? fd.passengerCapacity
          : ((fd?.noOfPassenger != null && fd!.noOfPassenger!.isNotEmpty)
              ? fd.noOfPassenger
              : ld?.passengerCapacity);
      if (passCapVal != null && passCapVal.isNotEmpty) {
        _pPassengerCapacity.text = passCapVal;
      }

      final amcPriceVal = (fd?.amcPrice != null && fd!.amcPrice!.isNotEmpty && fd.amcPrice != "0")
          ? fd.amcPrice
          : ((fd?.amcAmount != null && fd!.amcAmount!.isNotEmpty && fd.amcAmount != "0.00")
              ? fd.amcAmount
              : ((fd?.grandTotal != null && fd!.grandTotal!.isNotEmpty && fd.grandTotal != "0.00")
                  ? fd.grandTotal
                  : (ld?.amcAmount ?? ld?.totalSalePrice)));
      if (amcPriceVal != null && amcPriceVal.isNotEmpty) {
        _amcPriceCtrl.text = amcPriceVal;
      }

      // Populate Supply & Installation / Estimation & Pricing fields from followup details
      if (fd != null) {
        if (fd.clientName != null && fd.clientName!.isNotEmpty) {
          _pClientName.text = fd.clientName!;
        }
        if (fd.phone != null && fd.phone!.isNotEmpty) {
          _pPhone.text = fd.phone!;
        }
        if (fd.location != null && fd.location!.isNotEmpty) {
          _pLocation.text = fd.location!;
        }
        if (fd.elevatorType != null && fd.elevatorType!.isNotEmpty) {
          _pElevatorType.text = fd.elevatorType!;
        }
        if (fd.typeOfOpening != null && fd.typeOfOpening!.isNotEmpty) {
          _pTypeOfOpening.text = fd.typeOfOpening!;
        }
        if (fd.liftCapacity != null && fd.liftCapacity!.isNotEmpty) {
          _pCapacity.text = fd.liftCapacity!;
        }
        if (fd.shaftWidth != null && fd.shaftWidth!.isNotEmpty) {
          _pShaftWidth.text = fd.shaftWidth!;
        }
        if (fd.shaftDepth != null && fd.shaftDepth!.isNotEmpty) {
          _pShaftDepth.text = fd.shaftDepth!;
        }
        if (fd.pitDepth != null && fd.pitDepth!.isNotEmpty) {
          _pPitDepth.text = fd.pitDepth!;
        }
        if (fd.travelHeight != null && fd.travelHeight!.isNotEmpty) {
          _pTravelHeight.text = fd.travelHeight!;
        }
        if (fd.overHeadHeight != null && fd.overHeadHeight!.isNotEmpty) {
          _pOverheadHeight.text = fd.overHeadHeight!;
        }
        if (fd.doorOpeningSize != null && fd.doorOpeningSize!.isNotEmpty) {
          _pDoorOpeningSize.text = fd.doorOpeningSize!;
        }
        if (fd.wr != null && fd.wr!.isNotEmpty) {
          _pWarranty.text = fd.wr!;
        }
        if (fd.amc != null && fd.amc!.isNotEmpty) {
          _pAmc.text = fd.amc!;
        }
        if (fd.factoryPrice != null && fd.factoryPrice!.isNotEmpty) {
          _pFactoryPrice.text = fd.factoryPrice!;
        }
        if (fd.transportation != null && fd.transportation!.isNotEmpty) {
          _pTransportation.text = fd.transportation!;
        }
        if (fd.installationCharge != null && fd.installationCharge!.isNotEmpty) {
          _pInstallation.text = fd.installationCharge!;
        }
        if (fd.testingCommissioning != null && fd.testingCommissioning!.isNotEmpty) {
          _pTesting.text = fd.testingCommissioning!;
        }
        if (fd.consumables != null && fd.consumables!.isNotEmpty) {
          _pConsumables.text = fd.consumables!;
        }
        if (fd.additionalFactoryCharges != null && fd.additionalFactoryCharges!.isNotEmpty) {
          _pAdditionalFactory.text = fd.additionalFactoryCharges!;
        }
        if (fd.additionalAmount != null && fd.additionalAmount!.isNotEmpty) {
          _pAdditional.text = fd.additionalAmount!;
        }
        if (fd.amcAmount != null && fd.amcAmount!.isNotEmpty) {
          _pAmcAmount.text = fd.amcAmount!;
        }
        if (fd.price != null && fd.price!.isNotEmpty) {
          _pUnitPrice.text = fd.price!;
        }
        if (fd.compProfit != null && fd.compProfit!.isNotEmpty) {
          _pCompanyProfit.text = fd.compProfit!;
        }
        if (fd.compProfitAmount != null && fd.compProfitAmount!.isNotEmpty) {
          _pCompanyProfitAmount.text = fd.compProfitAmount!;
        }
        if (fd.salesCommission != null && fd.salesCommission!.isNotEmpty) {
          _pSalesCommission.text = fd.salesCommission!;
        }
        if (fd.salesCommissionAmount != null && fd.salesCommissionAmount!.isNotEmpty) {
          _pSalesCommissionAmount.text = fd.salesCommissionAmount!;
        }
        if (fd.subTotal != null && fd.subTotal!.isNotEmpty) {
          _pSubTotal.text = fd.subTotal!;
        }
        if (fd.tax != null && fd.tax!.isNotEmpty) {
          _pTaxPercentage.text = fd.tax!;
        }
        if (fd.taxAmount != null && fd.taxAmount!.isNotEmpty) {
          _pTaxAmount.text = fd.taxAmount!;
        }
        if (fd.grandTotal != null && fd.grandTotal!.isNotEmpty) {
          _pTotalSalePrice.text = fd.grandTotal!;
        }

        if (fd.liftType != null && fd.liftType!.isNotEmpty) _pLiftTypeId = fd.liftType;
        if (fd.openingType != null && fd.openingType!.isNotEmpty) _pOpeningId = fd.openingType;
        if (fd.doorOpening != null && fd.doorOpening!.isNotEmpty) _pDoorOpeningId = fd.doorOpening;
        if (fd.cabinSideWall != null && fd.cabinSideWall!.isNotEmpty) _pCabinSideWallId = fd.cabinSideWall;
        if (fd.landingDoor != null && fd.landingDoor!.isNotEmpty) _pLandingDoorId = fd.landingDoor;
        if (fd.cop != null && fd.cop!.isNotEmpty) _pCopId = fd.cop;
        if (fd.lop != null && fd.lop!.isNotEmpty) _pLopId = fd.lop;
        if (fd.taxType != null && fd.taxType!.isNotEmpty) _pTaxType = fd.taxType;
      }

      if (ld != null) {
        _initEstimationFromData(ld);
      }

      callResultReasonList();
      _fetchLeadExtraSettings(callResultId);

      if (leadDetails != null && leadDetails!.data != null) {
        whatsappLead.text = leadDetails!.data!.whatsaAppNumber ?? '';
        emailLead.text = leadDetails!.data!.emailId ?? '';

        if (productSectionModel != null && productSectionModel!.data != null) {
          String leadProductsRaw = leadDetails!.data!.productsOnAdd ?? '';
          if (leadProductsRaw.isNotEmpty) {
            List<String> assignedProductIds = leadProductsRaw.split(',');
            _selectedProducts = productSectionModel!.data!
                .where(
                    (prod) => assignedProductIds.contains(prod.id.toString()))
                .toList();
          }
        }
      }
      _initializeAdditionalFields();
    });
  }

  editFollowup() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult is List<ConnectivityResult>) {
      if (!connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi)) {
        _showNoNetworkSnackbar();
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    if (callResultId == '') {
      Common.toastMessaage('Choose any Status', Colors.red);
      return;
    }

    if (callResponseId.isEmpty) {
      Common.toastMessaage('Select Call Status', Colors.red);
      return;
    }

    bool nextFollowUpRequired =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (nextFollowUpRequired &&
        (nextFollowupDate1.text.isEmpty ||
            nextFollowupDate1.text.contains("0001"))) {
      Common.toastMessaage('Select Next Followup Date', Colors.red);
      return;
    }

    bool reasonRequired = leadSettings?.isReasonRequiredBool ?? false;
    if (reasonRequired &&
        (callResultReasonId.isEmpty ||
            callResultReasonId == '0' ||
            callResultReasonId == 'null')) {
      Common.toastMessaage('Select Tag', Colors.red);
      return;
    }

    final isEstimationStage = callResultId == '16' ||
        callResult == 'Estimation & Pricing' ||
        callResult.toLowerCase().contains('estimation');

    final isAmcCategory = leadTypeId == '11' ||
        leadType.trim().toUpperCase() == 'AMC';

    if (isEstimationStage && isAmcCategory) {
      if (_amcPriceCtrl.text.trim().isNotEmpty && cost.text.trim().isEmpty) {
        cost.text = _amcPriceCtrl.text.trim();
      }
    }

    if (context.mounted) {
      Common.showProgressDialog(context, "Loading..");
    }

    _additionalValues.clear();
    for (int i = 0; i < _additionalCtrls.length; i++) {
      if (i < commonDetails!.data.additionalFields.length) {
        _additionalValues.add({
          "id": commonDetails!.data.additionalFields[i].id,
          "name": commonDetails!.data.additionalFields[i].fieldName,
          "value": _additionalCtrls[i].text,
        });
      }
    }

    final pricingBody = isEstimationStage ? _buildPricingBody() : null;

    EditLeadFollowupModel object1 = await HttpService.editLeadsFollowupUpdated(
        widget.token,
        widget.callFollowupId,
        callResultId,
        nextFollowupDate1.text,
        cost.text,
        leadTypeId,
        leadSubTypeId,
        remarks.text,
        calledDate1.text,
        widget.callMasterId,
        callResponseId,
        callResultReasonId,
        checked,
        timeBefore.text,
        _additionalValues,
        whatsappLead: whatsappLead.text,
        emailLead: emailLead.text,
        products: _selectedProducts.map((p) => p.id).join(','),
        pricingData: pricingBody,
        amcType: _amcTypeCtrl.text.trim().isNotEmpty
            ? _amcTypeCtrl.text.trim()
            : _amcTypeSelected,
        liftBrand: _liftBrandCtrl.text.trim(),
        ageOfLift: _ageOfLiftCtrl.text.trim(),
        subject: _pQuotationTitle.text.trim(),
        passengerCapacity: _pPassengerCapacity.text.trim(),
        amcPrice: _amcPriceCtrl.text.trim(),
        warranty: _pWarranty.text.trim(),
        amc: _pAmc.text.trim());

    if (context.mounted) Navigator.pop(context);

    if (object1.status == true) {
      Common.toastMessaage(object1.message, Colors.green);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      Common.toastMessaage(object1.message, Colors.red);
    }
  }

  void _showNoNetworkSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Network Found..Try Again Later..'),
        backgroundColor: Colors.redAccent,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
      ),
    );
  }

  callResultReasonList() async {
    callResultReason =
        await HttpService.callResultReasonLiat(widget.token, callResultId);
    if (commonDetails != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: result == false
          ? _buildNoNetworkView()
          : isLoading
              ? Center(
                  child: Lottie.asset('assets/main/loading.json', width: 150))
              : commonDetails == null
                  ? _buildErrorView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Edit Followup',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
          const Text(
            'No Network Found!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: getData,
            child: Container(
              width: 120,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: getData,
            child: const Text('Retry'),
          ),
        ],
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
                decoration: _inputDecoration('AMC Type *', Icons.merge_type),
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
                decoration:
                    _inputDecoration('Lift Brand *', Icons.branding_watermark),
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
                decoration:
                    _inputDecoration('Age of Lift *', Icons.access_time),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _pQuotationTitle,
                decoration: _inputDecoration('Subject *', Icons.title),
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
                decoration: _inputDecoration(
                    'Passenger Capacity/KG *', Icons.people_outline),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _amcPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Price *', Icons.currency_rupee),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    final isEstimationStage = callResultId == '16' ||
        callResult == 'Estimation & Pricing' ||
        callResult.toLowerCase().contains('estimation');

    final isAmcCategory = leadTypeId == '11' ||
        leadType.trim().toUpperCase() == 'AMC';

    final isRepairCategory = leadTypeId == '12' ||
        leadType.trim().toUpperCase() == 'REPAIR' ||
        leadType.trim().toLowerCase() == 'repairing';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Call Information',
              icon: Icons.phone_in_talk_outlined,
              children: [
                const SizedBox(height: 12),
                _buildCalledDateField(),
                const SizedBox(height: 12),
                _buildCallResponseField(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Lead Info',
              icon: Icons.assignment_outlined,
              children: [
                const SizedBox(height: 12),
                _buildCallResultField(),
                const SizedBox(height: 12),
                if (callResultReason?.data?.isNotEmpty ?? false)
                  _buildCallReasonField(),
                const SizedBox(height: 12),
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : (callResultId == '2'))
                  _buildNextFollowupField(),
              ],
            ),
            if (isEstimationStage) ...[
              const SizedBox(height: 12),
              if (isAmcCategory) ...[
                _buildAMCSection(),
              ] else if (isRepairCategory) ...[
                EstimationPricingCard(
                  data: estimationDetails?.data,
                  permissions: userPermissions,
                  showEstimation: true,
                  showPricing: false,
                  initialClientName: _pClientName.text,
                  initialPhone: _pPhone.text,
                  initialLocation: _pLocation.text,
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
              ] else ...[
                EstimationPricingCard(
                  data: estimationDetails?.data,
                  permissions: userPermissions,
                  showEstimation: true,
                  showPricing: false,
                  initialClientName: _pClientName.text,
                  initialPhone: _pPhone.text,
                  initialLocation: _pLocation.text,
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
              ],
            ],
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Product Details',
              icon: Icons.inventory_2_outlined,
              children: [
                const SizedBox(height: 12),
                _buildProductSelection(),
                const SizedBox(height: 12),
                _buildCostField(),
                const SizedBox(height: 12),
                _buildLeadCategoryField(),
                const SizedBox(height: 12),
                if (leadSubTypeList?.data?.isNotEmpty ?? false)
                  _buildLeadSubCategoryField(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Contact Info',
              icon: Icons.contact_phone_outlined,
              children: [
                const SizedBox(height: 12),
                _buildContactRow(),
                const SizedBox(height: 12),
                _buildRemarksField(),
              ],
            ),
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty)
              const SizedBox(height: 12),
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty)
              _buildSectionCard(
                title: 'Additional Fields',
                icon: Icons.more_outlined,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFieldsUI(),
                ],
              ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
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
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCalledDateField() {
    return TextFormField(
      controller: calledDate1,
      readOnly: true,
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (selectedDate != null) {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (selectedTime != null) {
            final dateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            calledDate1.text =
                DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
          }
        }
      },
      validator: (v) => v!.isEmpty ? 'Called date is required' : null,
      decoration: _inputDecoration('Called Date *', Icons.calendar_today),
    );
  }

  Widget _buildContactRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: whatsappLead,
            keyboardType: TextInputType.phone,
            decoration:
                _inputDecoration('WhatsApp Number', FontAwesomeIcons.whatsapp)
                    .copyWith(
                        prefixIcon: Icon(FontAwesomeIcons.whatsapp,
                            color: Colors.green, size: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: emailLead,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email ID', Icons.email),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (productSectionModel?.data != null) {
                    _showProductSelectionDialog(productSectionModel!.data!);
                  } else {
                    Common.toastMessaage(
                        'Products not loaded yet', Colors.orange);
                  }
                },
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
                  getData();
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
        if (_selectedProducts.isNotEmpty) ...[
          const SizedBox(height: 12),
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
                              _updateCostFromProducts();
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
      ],
    );
  }

  Widget _buildCallResultField() {
    return GestureDetector(
      onTap: () => _showSelectionDialog(
        title: 'Lead Stages',
        items: commonDetails!.data.callResult
            .map((cr) => cr.callResult.toString())
            .toList(),
        onSelected: (index) {
          String newCallResultId =
              commonDetails!.data.callResult[index].callResultId.toString();
          setState(() {
            if (newCallResultId != callResultId) {
              nextFollowupDate1.clear();
            }
            callResultVal.text =
                commonDetails!.data.callResult[index].callResult.toString();
            callResult =
                commonDetails!.data.callResult[index].callResult.toString();
            callResultId = newCallResultId;
            // Clear stage-specific tags when stage changes
            callResultReasonId = '';
            callResultReasonName = 'Tag';
            callReasonVal.clear();

            callResultReasonList();
            _fetchLeadExtraSettings(callResultId);
          });
        },
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResultVal,
          validator: (v) => v!.isEmpty ? 'Lead Stages is required' : null,
          decoration:
              _inputDecoration('Lead Stages *', Icons.assignment_turned_in),
        ),
      ),
    );
  }

  Widget _buildNextFollowupField() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: checked ? 3 : 4,
              child: TextFormField(
                controller: nextFollowupDate1,
                readOnly: true,
                onTap: () async {
                  DateTime now = DateTime.now();
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      final selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      if (selectedDateTime.isAfter(now)) {
                        setState(() {
                          nextFollowupDate1.text =
                              DateFormat('dd-MM-yyyy hh:mm a')
                                  .format(selectedDateTime);

                          // Auto-adjust reminder if needed
                          if (checked && timeBefore.text.isNotEmpty) {
                            int minutes = int.tryParse(timeBefore.text) ?? 10;
                            DateTime reminderTime = selectedDateTime
                                .subtract(Duration(minutes: minutes));
                            if (reminderTime.isBefore(DateTime.now())) {
                              int maxMinutes = selectedDateTime
                                  .difference(DateTime.now())
                                  .inMinutes;
                              if (maxMinutes <= 0) {
                                timeBefore.text = "0";
                              } else {
                                timeBefore.text = maxMinutes.toString();
                              }
                              Common.toastMessaage(
                                  'Reminder time adjusted to ${timeBefore.text} mins before',
                                  Colors.orange);
                            }
                          }
                        });
                      } else {
                        Common.toastMessaage(
                          "You cannot choose a past time for the follow-up date",
                          Colors.red,
                        );
                      }
                    }
                  }
                },
                decoration: _inputDecoration(
                    (leadSettings?.isFollowupRequiredBool ??
                            (callResultId == '2'))
                        ? 'Next Followup Date *'
                        : 'Next Followup Date',
                    Icons.calendar_month),
              ),
            ),
            if (checked)
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: timeBefore,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            int val = int.tryParse(timeBefore.text) ?? 0;
                            timeBefore.text = (val + 1).toString();
                          },
                          child: const Icon(Icons.arrow_drop_up, size: 20),
                        ),
                        InkWell(
                          onTap: () {
                            int val = int.tryParse(timeBefore.text) ?? 0;
                            timeBefore.text =
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
              onTap: () {
                setState(() {
                  checked = !checked;
                  if (checked && nextFollowupDate1.text.isNotEmpty) {
                    try {
                      DateTime dt = DateFormat('dd-MM-yyyy hh:mm a')
                          .parse(nextFollowupDate1.text);
                      int minutes = int.tryParse(timeBefore.text) ?? 10;
                      DateTime reminderTime =
                          dt.subtract(Duration(minutes: minutes));
                      if (reminderTime.isBefore(DateTime.now())) {
                        int maxMinutes =
                            dt.difference(DateTime.now()).inMinutes;
                        if (maxMinutes <= 0) {
                          timeBefore.text = "0";
                        } else {
                          timeBefore.text = maxMinutes.toString();
                        }
                        Common.toastMessaage(
                            'Reminder time adjusted to ${timeBefore.text} mins before',
                            Colors.orange);
                      }
                    } catch (e) {
                      // ignore
                    }
                  }
                });
              },
              child: Icon(
                Icons.notifications,
                color: checked ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallReasonField() {
    return GestureDetector(
      onTap: () => _showSelectionDialog(
        title: 'Tags',
        items: callResultReason!.data!.map((r) => r.reason.toString()).toList(),
        onSelected: (index) {
          setState(() {
            callResultReasonName =
                callResultReason!.data![index].reason.toString();
            callResultReasonId = callResultReason!.data![index].id.toString();
            callReasonVal.text =
                callResultReason!.data![index].reason.toString();
          });
        },
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callReasonVal,
          decoration: _inputDecoration(
              (leadSettings?.isReasonRequiredBool ?? false) ? 'Tags *' : 'Tags',
              Icons.reply_all_sharp),
        ),
      ),
    );
  }

  Widget _buildCallResponseField() {
    return GestureDetector(
      onTap: () => _showSelectionDialog(
        title: 'Call Status',
        items: commonDetails!.data.callResponseStatus
            .map((r) => r.callResponse.toString())
            .toList(),
        onSelected: (index) {
          setState(() {
            callResponseVal.text = commonDetails!
                .data.callResponseStatus[index].callResponse
                .toString();
            callResponse = commonDetails!
                .data.callResponseStatus[index].callResponse
                .toString();
            callResponseId = commonDetails!
                .data.callResponseStatus[index].callResponseId
                .toString();
          });
        },
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResponseVal,
          decoration: _inputDecoration('Call Status *', Icons.add_call),
        ),
      ),
    );
  }

  Widget _buildLeadCategoryField() {
    return GestureDetector(
      onTap: () => _showLeadCategoryDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: leadTypeVal,
          decoration: _inputDecoration('Lead Category', Icons.category),
        ),
      ),
    );
  }

  Widget _buildLeadSubCategoryField() {
    return GestureDetector(
      onTap: () => _showLeadSubCategoryDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: leadSubTypeVal,
          decoration: _inputDecoration('Lead Sub Category', Icons.subtitles),
        ),
      ),
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: cost,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('Cost', Icons.currency_rupee),
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: remarks,
      maxLines: 3,
      decoration: _inputDecoration('Remarks', Icons.note).copyWith(
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: editFollowup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a86c9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Update Followup',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon,
      {bool isDense = false}) {
    return InputDecoration(
      isDense: isDense,
      label: RichText(
        text: TextSpan(
          text: label.replaceAll(' *', ''),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            if (label.contains('*'))
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  void _showSelectionDialog({
    required String title,
    required List<String> items,
    required Function(int) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController searchCtrl = TextEditingController();
        List<String> filteredItems = List.from(items);

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onChanged: (v) {
                        setState(() {
                          filteredItems = items
                              .where((item) =>
                                  item.toLowerCase().contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (_, i) {
                          return ListTile(
                            title: Text(filteredItems[i]),
                            onTap: () {
                              final originalIndex =
                                  items.indexOf(filteredItems[i]);
                              onSelected(originalIndex);
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

  void _showLeadCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.leadCategory);

        return StatefulBuilder(
          builder: (ctx, setState) {
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
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          filtered = commonDetails!.data.leadCategory
                              .where((c) => c.leadCategory
                                  .toString()
                                  .toLowerCase()
                                  .contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          return ListTile(
                            title: Text(filtered[i].leadCategory.toString()),
                            onTap: () async {
                              leadSubTypeList = await HttpService.leadSubType(
                                  filtered[i].leadCategoryId.toString());
                              this.setState(() {
                                leadTypeVal.text =
                                    filtered[i].leadCategory.toString();
                                leadType = filtered[i].leadCategory.toString();
                                leadTypeId =
                                    filtered[i].leadCategoryId.toString();
                                leadSubType = 'Lead Sub Category';
                                leadSubTypeId = '';
                                leadSubTypeVal.text = 'Lead Sub Category';
                              });
                              if (context.mounted) Navigator.pop(context);
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

  void _showLeadSubCategoryDialog() {
    if (leadSubTypeList == null) return;

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
                return ListTile(
                  title: Text(
                      leadSubTypeList!.data![i].leadSubCategory.toString()),
                  onTap: () {
                    setState(() {
                      leadSubType =
                          leadSubTypeList!.data![i].leadSubCategory.toString();
                      leadSubTypeId = leadSubTypeList!
                          .data![i].leadSubCategoryId
                          .toString();
                      leadSubTypeVal.text = leadSubType;
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

  void _showProductSelectionDialog(List<LeadProduct> products) {
    List<LeadProduct> filteredProducts = List.from(products);
    List<LeadProduct> localSelected = List.from(_selectedProducts);
    TextEditingController searchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Products'),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          filteredProducts = products
                              .where((p) => (p.productName ?? '')
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final isSelected =
                              localSelected.any((p) => p.id == product.id);

                          return CheckboxListTile(
                            title: Text(product.productName ?? 'Unknown'),
                            subtitle: Text('₹ ${product.totalAmount ?? '0'}'),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  localSelected.add(product);
                                } else {
                                  localSelected
                                      .removeWhere((p) => p.id == product.id);
                                }
                              });
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedProducts = List.from(localSelected);
                      _updateCostFromProducts();
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateCostFromProducts() {
    double total = 0;
    for (var prod in _selectedProducts) {
      if (prod.totalAmount != null && prod.totalAmount!.isNotEmpty) {
        total += double.tryParse(prod.totalAmount!) ?? 0.0;
      }
    }
    setState(() {
      cost.text = total > 0 ? total.toStringAsFixed(2) : "";
    });
  }
}
