import 'package:flutter/material.dart';
import '../models/lead_management/leadDetailsModel.dart';
import '../models/lead_management/estimation_pricing_dropdown_model.dart';
import '../models/userPermissionModel.dart';
import '../service/service.dart';

class EstimationPricingCard extends StatefulWidget {
  final dynamic data;
  final bool showPricing;
  final String? initialClientName;
  final String? initialPhone;
  final String? initialLocation;
  final UserPermissionModel? permissions;

  // Estimation controllers
  final TextEditingController? quotationTitleCtrl;
  final TextEditingController? quotationCtrl;
  final TextEditingController? clientNameCtrl;
  final TextEditingController? phoneCtrl;
  final TextEditingController? locationCtrl;
  final TextEditingController? elevatorTypeCtrl;
  final TextEditingController? typeOfOpeningCtrl;
  final TextEditingController? capacityCtrl;
  final TextEditingController? passengerCapacityCtrl;
  final TextEditingController? shaftWidthCtrl;
  final TextEditingController? shaftDepthCtrl;
  final TextEditingController? pitDepthCtrl;
  final TextEditingController? travelHeightCtrl;
  final TextEditingController? overheadHeightCtrl;
  final TextEditingController? warrantyCtrl;
  final TextEditingController? amcCtrl;

  // Estimation dropdown values
  final String? liftTypeId;
  final String? openingId;
  final String? doorOpeningId;
  final String? cabinSideWallId;
  final String? landingDoorId;
  final String? copId;
  final String? lopId;

  // Estimation dropdown callbacks
  final ValueChanged<String?>? onLiftTypeChanged;
  final ValueChanged<String?>? onOpeningChanged;
  final ValueChanged<String?>? onDoorOpeningChanged;
  final ValueChanged<String?>? onCabinSideWallChanged;
  final ValueChanged<String?>? onLandingDoorChanged;
  final ValueChanged<String?>? onCopChanged;
  final ValueChanged<String?>? onLopChanged;

  // Pricing controllers
  final TextEditingController? factoryPriceCtrl;
  final TextEditingController? transportationCtrl;
  final TextEditingController? installationCtrl;
  final TextEditingController? testingCtrl;
  final TextEditingController? consumablesCtrl;
  final TextEditingController? additionalFactoryCtrl;
  final TextEditingController? additionalCtrl;
  final TextEditingController? amcAmountCtrl;
  final TextEditingController? quantityCtrl;
  final TextEditingController? unitPriceCtrl;
  final TextEditingController? companyProfitCtrl;
  final TextEditingController? companyProfitAmountCtrl;
  final TextEditingController? salesCommissionCtrl;
  final TextEditingController? salesCommissionAmountCtrl;
  final TextEditingController? subTotalCtrl;
  final TextEditingController? taxPercentageCtrl;
  final TextEditingController? taxAmountCtrl;
  final TextEditingController? totalSalePriceCtrl;

  final String? taxType;
  final ValueChanged<String?>? onTaxTypeChanged;

  const EstimationPricingCard({
    super.key,
    this.data,
    this.showPricing = false,
    this.initialClientName,
    this.initialPhone,
    this.initialLocation,
    this.quotationTitleCtrl,
    this.quotationCtrl,
    this.clientNameCtrl,
    this.phoneCtrl,
    this.locationCtrl,
    this.elevatorTypeCtrl,
    this.typeOfOpeningCtrl,
    this.capacityCtrl,
    this.passengerCapacityCtrl,
    this.shaftWidthCtrl,
    this.shaftDepthCtrl,
    this.pitDepthCtrl,
    this.travelHeightCtrl,
    this.overheadHeightCtrl,
    this.warrantyCtrl,
    this.amcCtrl,
    this.liftTypeId,
    this.openingId,
    this.doorOpeningId,
    this.cabinSideWallId,
    this.landingDoorId,
    this.copId,
    this.lopId,
    this.onLiftTypeChanged,
    this.onOpeningChanged,
    this.onDoorOpeningChanged,
    this.onCabinSideWallChanged,
    this.onLandingDoorChanged,
    this.onCopChanged,
    this.onLopChanged,
    this.factoryPriceCtrl,
    this.transportationCtrl,
    this.installationCtrl,
    this.testingCtrl,
    this.consumablesCtrl,
    this.additionalFactoryCtrl,
    this.additionalCtrl,
    this.amcAmountCtrl,
    this.quantityCtrl,
    this.unitPriceCtrl,
    this.companyProfitCtrl,
    this.companyProfitAmountCtrl,
    this.salesCommissionCtrl,
    this.salesCommissionAmountCtrl,
    this.subTotalCtrl,
    this.taxPercentageCtrl,
    this.taxAmountCtrl,
    this.totalSalePriceCtrl,
    this.taxType,
    this.onTaxTypeChanged,
    this.permissions,
  });

  @override
  State<EstimationPricingCard> createState() => _EstimationPricingCardState();
}

class _EstimationPricingCardState extends State<EstimationPricingCard> {
  // ============================================================
  // INTERNAL CONTROLLERS
  // ============================================================

  late final TextEditingController _internalQuotationTitle;
  late final TextEditingController _internalQuotation;
  late final TextEditingController _internalClientName;
  late final TextEditingController _internalPhone;
  late final TextEditingController _internalLocation;
  late final TextEditingController _internalElevatorType;
  late final TextEditingController _internalTypeOfOpening;
  late final TextEditingController _internalCapacity;
  late final TextEditingController _internalPassengerCapacity;
  late final TextEditingController _internalShaftWidth;
  late final TextEditingController _internalShaftDepth;
  late final TextEditingController _internalPitDepth;
  late final TextEditingController _internalTravelHeight;
  late final TextEditingController _internalOverheadHeight;
  late final TextEditingController _internalWarranty;
  late final TextEditingController _internalAmc;

  late final TextEditingController _internalFactoryPrice;
  late final TextEditingController _internalTransportation;
  late final TextEditingController _internalInstallation;
  late final TextEditingController _internalTesting;
  late final TextEditingController _internalConsumables;
  late final TextEditingController _internalAdditionalFactory;
  late final TextEditingController _internalAdditional;
  late final TextEditingController _internalAmcAmount;
  late final TextEditingController _internalQuantity;
  late final TextEditingController _internalUnitPrice;
  late final TextEditingController _internalCompanyProfit;
  late final TextEditingController _internalCompanyProfitAmount;
  late final TextEditingController _internalSalesCommission;
  late final TextEditingController _internalSalesCommissionAmount;
  late final TextEditingController _internalSubTotal;
  late final TextEditingController _internalTaxPercentage;
  late final TextEditingController _internalTaxAmount;
  late final TextEditingController _internalTotalSalePrice;

  // ============================================================
  // ACTIVE CONTROLLERS
  // ============================================================

  TextEditingController get _cQuotationTitle =>
      widget.quotationTitleCtrl ?? _internalQuotationTitle;

  TextEditingController get _cQuotation =>
      widget.quotationCtrl ?? _internalQuotation;

  TextEditingController get _cClientName =>
      widget.clientNameCtrl ?? _internalClientName;

  TextEditingController get _cPhone => widget.phoneCtrl ?? _internalPhone;

  TextEditingController get _cLocation =>
      widget.locationCtrl ?? _internalLocation;

  TextEditingController get _cElevatorType =>
      widget.elevatorTypeCtrl ?? _internalElevatorType;

  TextEditingController get _cTypeOfOpening =>
      widget.typeOfOpeningCtrl ?? _internalTypeOfOpening;

  TextEditingController get _cCapacity =>
      widget.capacityCtrl ?? _internalCapacity;

  TextEditingController get _cPassengerCapacity =>
      widget.passengerCapacityCtrl ?? _internalPassengerCapacity;

  TextEditingController get _cShaftWidth =>
      widget.shaftWidthCtrl ?? _internalShaftWidth;

  TextEditingController get _cShaftDepth =>
      widget.shaftDepthCtrl ?? _internalShaftDepth;

  TextEditingController get _cPitDepth =>
      widget.pitDepthCtrl ?? _internalPitDepth;

  TextEditingController get _cTravelHeight =>
      widget.travelHeightCtrl ?? _internalTravelHeight;

  TextEditingController get _cOverheadHeight =>
      widget.overheadHeightCtrl ?? _internalOverheadHeight;

  TextEditingController get _cWarranty =>
      widget.warrantyCtrl ?? _internalWarranty;

  TextEditingController get _cAmc => widget.amcCtrl ?? _internalAmc;

  TextEditingController get _cFactoryPrice =>
      widget.factoryPriceCtrl ?? _internalFactoryPrice;

  TextEditingController get _cTransportation =>
      widget.transportationCtrl ?? _internalTransportation;

  TextEditingController get _cInstallation =>
      widget.installationCtrl ?? _internalInstallation;

  TextEditingController get _cTesting => widget.testingCtrl ?? _internalTesting;

  TextEditingController get _cConsumables =>
      widget.consumablesCtrl ?? _internalConsumables;

  TextEditingController get _cAdditionalFactory =>
      widget.additionalFactoryCtrl ?? _internalAdditionalFactory;

  TextEditingController get _cAdditional =>
      widget.additionalCtrl ?? _internalAdditional;

  TextEditingController get _cAmcAmount =>
      widget.amcAmountCtrl ?? _internalAmcAmount;

  TextEditingController get _cQuantity =>
      widget.quantityCtrl ?? _internalQuantity;

  TextEditingController get _cUnitPrice =>
      widget.unitPriceCtrl ?? _internalUnitPrice;

  TextEditingController get _cCompanyProfit =>
      widget.companyProfitCtrl ?? _internalCompanyProfit;

  TextEditingController get _cCompanyProfitAmount =>
      widget.companyProfitAmountCtrl ?? _internalCompanyProfitAmount;

  TextEditingController get _cSalesCommission =>
      widget.salesCommissionCtrl ?? _internalSalesCommission;

  TextEditingController get _cSalesCommissionAmount =>
      widget.salesCommissionAmountCtrl ?? _internalSalesCommissionAmount;

  TextEditingController get _cSubTotal =>
      widget.subTotalCtrl ?? _internalSubTotal;

  TextEditingController get _cTaxPercentage =>
      widget.taxPercentageCtrl ?? _internalTaxPercentage;

  TextEditingController get _cTaxAmount =>
      widget.taxAmountCtrl ?? _internalTaxAmount;

  TextEditingController get _cTotalSalePrice =>
      widget.totalSalePriceCtrl ?? _internalTotalSalePrice;

  // ============================================================
  // DROPDOWN INTERNAL VALUES
  // ============================================================

  String? _internalLiftTypeId;
  String? _internalOpeningId;
  String? _internalDoorOpeningId;
  String? _internalCabinSideWallId;
  String? _internalLandingDoorId;
  String? _internalCopId;
  String? _internalLopId;
  String? _internalTaxType;

  String? get _liftTypeId => widget.liftTypeId ?? _internalLiftTypeId;

  String? get _openingId => widget.openingId ?? _internalOpeningId;

  String? get _doorOpeningId => widget.doorOpeningId ?? _internalDoorOpeningId;

  String? get _cabinSideWallId =>
      widget.cabinSideWallId ?? _internalCabinSideWallId;

  String? get _landingDoorId => widget.landingDoorId ?? _internalLandingDoorId;

  String? get _copId => widget.copId ?? _internalCopId;

  String? get _lopId => widget.lopId ?? _internalLopId;

  String? get _taxType => widget.taxType ?? _internalTaxType;

  // ============================================================
  // DROPDOWN API STATE
  // ============================================================

  bool _isLoadingEstimationDropdowns = false;

  EstimationPricingDropdownData? _estimationDropdownData;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _internalQuotationTitle = TextEditingController();

    _internalQuotation = TextEditingController();

    _internalClientName = TextEditingController(
      text: widget.initialClientName ?? '',
    );

    _internalPhone = TextEditingController(
      text: widget.initialPhone ?? '',
    );

    _internalLocation = TextEditingController(
      text: widget.initialLocation ?? '',
    );

    _internalElevatorType = TextEditingController();

    _internalTypeOfOpening = TextEditingController();

    _internalCapacity = TextEditingController();

    _internalPassengerCapacity = TextEditingController();

    _internalShaftWidth = TextEditingController();

    _internalShaftDepth = TextEditingController();

    _internalPitDepth = TextEditingController();

    _internalTravelHeight = TextEditingController();

    _internalOverheadHeight = TextEditingController();

    _internalWarranty = TextEditingController();

    _internalAmc = TextEditingController();

    _internalFactoryPrice = TextEditingController();

    _internalTransportation = TextEditingController();

    _internalInstallation = TextEditingController();

    _internalTesting = TextEditingController();

    _internalConsumables = TextEditingController();

    _internalAdditionalFactory = TextEditingController();

    _internalAdditional = TextEditingController();

    _internalAmcAmount = TextEditingController();

    _internalQuantity = TextEditingController(text: '1');

    _internalUnitPrice = TextEditingController();

    _internalCompanyProfit = TextEditingController();

    _internalCompanyProfitAmount = TextEditingController();

    _internalSalesCommission = TextEditingController();

    _internalSalesCommissionAmount = TextEditingController();

    _internalSubTotal = TextEditingController();

    _internalTaxPercentage = TextEditingController();

    _internalTaxAmount = TextEditingController();

    _internalTotalSalePrice = TextEditingController();

    _initFromData();

    _loadEstimationPricingDropdowns();
  }

  // ============================================================
  // LOAD DROPDOWN API
  // ============================================================

  Future<void> _loadEstimationPricingDropdowns() async {
    if (!mounted) return;

    setState(() {
      _isLoadingEstimationDropdowns = true;
    });

    try {
      final response = await HttpService.getEstimationPricingDropdownValues();

      debugPrint(
        'ESTIMATION DROPDOWN RESPONSE = $response',
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final rawData = response['data'] as Map<String, dynamic>? ?? {};

        final parsed = EstimationPricingDropdownData.fromJson(rawData);

        debugPrint(
          'LIFT API COUNT = ${parsed.liftValues.length}',
        );

        debugPrint(
          'OPENING API COUNT = ${parsed.opening.length}',
        );

        debugPrint(
          'CABIN OPENING API COUNT = '
          '${parsed.cabinOpening.length}',
        );

        debugPrint(
          'CABIN SIDE WALL API COUNT = '
          '${parsed.cabinSideWall.length}',
        );

        debugPrint(
          'LANDING DOOR API COUNT = '
          '${parsed.landingDoor.length}',
        );

        debugPrint(
          'COP API COUNT = ${parsed.cop.length}',
        );

        debugPrint(
          'LOP API COUNT = ${parsed.lop.length}',
        );

        debugPrint(
          'TAX API COUNT = ${parsed.taxTypes.length}',
        );

        if (!mounted) return;

        setState(() {
          _estimationDropdownData = parsed;
        });
      } else {
        debugPrint(
          'ESTIMATION DROPDOWN API STATUS FALSE',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'ESTIMATION DROPDOWN ERROR = $e',
      );

      debugPrint(
        'ESTIMATION DROPDOWN STACK = $stackTrace',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEstimationDropdowns = false;
        });
      }
    }
  }

  // ============================================================
  // DATA INITIALIZATION
  // ============================================================

  bool _initializedFromData = false;

  @override
  void didUpdateWidget(
    covariant EstimationPricingCard oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.data != oldWidget.data && widget.data != null) {
      _initFromData();
    }

    if (widget.liftTypeId != oldWidget.liftTypeId) {
      _internalLiftTypeId = widget.liftTypeId;
    }

    if (widget.openingId != oldWidget.openingId) {
      _internalOpeningId = widget.openingId;
    }

    if (widget.doorOpeningId != oldWidget.doorOpeningId) {
      _internalDoorOpeningId = widget.doorOpeningId;
    }

    if (widget.cabinSideWallId != oldWidget.cabinSideWallId) {
      _internalCabinSideWallId = widget.cabinSideWallId;
    }

    if (widget.landingDoorId != oldWidget.landingDoorId) {
      _internalLandingDoorId = widget.landingDoorId;
    }

    if (widget.copId != oldWidget.copId) {
      _internalCopId = widget.copId;
    }

    if (widget.lopId != oldWidget.lopId) {
      _internalLopId = widget.lopId;
    }

    if (widget.taxType != oldWidget.taxType) {
      _internalTaxType = widget.taxType;
    }
  }

  void _initFromData() {
    final data = widget.data;

    if (data == null) return;
    if (_initializedFromData) return;

    _initializedFromData = true;

    if (widget.quotationTitleCtrl == null &&
        data.quotationTitle != null &&
        data.quotationTitle!.isNotEmpty) {
      _cQuotationTitle.text = data.quotationTitle ?? '';
    }

    // if (widget.quotationCtrl == null &&
    //     data.quotation != null &&
    //     data.quotation!.isNotEmpty) {
    //   _cQuotation.text = data.quotation ?? '';
    // }

    if (widget.clientNameCtrl == null) {
      if (data.clientName != null && data.clientName!.isNotEmpty) {
        _cClientName.text = data.clientName ?? '';
      } else if (widget.initialClientName != null &&
          widget.initialClientName!.isNotEmpty) {
        _cClientName.text = widget.initialClientName!;
      }
    }

    if (widget.phoneCtrl == null) {
      if (data.contactNumber1 != null && data.contactNumber1!.isNotEmpty) {
        _cPhone.text = data.contactNumber1 ?? '';
      } else if (widget.initialPhone != null &&
          widget.initialPhone!.isNotEmpty) {
        _cPhone.text = widget.initialPhone!;
      }
    }

    if (widget.locationCtrl == null) {
      if (data.location != null && data.location!.isNotEmpty) {
        _cLocation.text = data.location ?? '';
      } else if (widget.initialLocation != null &&
          widget.initialLocation!.isNotEmpty) {
        _cLocation.text = widget.initialLocation!;
      }
    }

    if (widget.elevatorTypeCtrl == null &&
        data.elevatorType != null &&
        data.elevatorType!.isNotEmpty) {
      _cElevatorType.text = data.elevatorType ?? '';
    }

    if (widget.typeOfOpeningCtrl == null &&
        data.typeOfOpening != null &&
        data.typeOfOpening!.isNotEmpty) {
      _cTypeOfOpening.text = data.typeOfOpening ?? '';
    }

    if (widget.capacityCtrl == null &&
        data.capacity != null &&
        data.capacity!.isNotEmpty) {
      _cCapacity.text = data.capacity ?? '';
    }

    if (widget.passengerCapacityCtrl == null &&
        data.passengerCapacity != null &&
        data.passengerCapacity!.isNotEmpty) {
      _cPassengerCapacity.text = data.passengerCapacity ?? '';
    }

    if (widget.shaftWidthCtrl == null &&
        data.shaftWidth != null &&
        data.shaftWidth!.isNotEmpty) {
      _cShaftWidth.text = data.shaftWidth ?? '';
    }

    if (widget.shaftDepthCtrl == null &&
        data.shaftDepth != null &&
        data.shaftDepth!.isNotEmpty) {
      _cShaftDepth.text = data.shaftDepth ?? '';
    }

    if (widget.pitDepthCtrl == null &&
        data.pitDepth != null &&
        data.pitDepth!.isNotEmpty) {
      _cPitDepth.text = data.pitDepth ?? '';
    }

    if (widget.travelHeightCtrl == null &&
        data.travelHeight != null &&
        data.travelHeight!.isNotEmpty) {
      _cTravelHeight.text = data.travelHeight ?? '';
    }

    if (widget.overheadHeightCtrl == null &&
        data.overheadHeight != null &&
        data.overheadHeight!.isNotEmpty) {
      _cOverheadHeight.text = data.overheadHeight ?? '';
    }

    if (widget.warrantyCtrl == null &&
        data.warranty != null &&
        data.warranty!.isNotEmpty) {
      _cWarranty.text = data.warranty ?? '';
    }

    if (widget.amcCtrl == null && data.amc != null && data.amc!.isNotEmpty) {
      _cAmc.text = data.amc ?? '';
    }

    // ==========================================================
    // PRICING DATA
    // ==========================================================

    if (widget.factoryPriceCtrl == null &&
        data.factoryPrice != null &&
        data.factoryPrice!.isNotEmpty) {
      _cFactoryPrice.text = data.factoryPrice ?? '';
    }

    if (widget.transportationCtrl == null &&
        data.transportationCharge != null &&
        data.transportationCharge!.isNotEmpty) {
      _cTransportation.text = data.transportationCharge ?? '';
    }

    if (widget.installationCtrl == null &&
        data.installationCharge != null &&
        data.installationCharge!.isNotEmpty) {
      _cInstallation.text = data.installationCharge ?? '';
    }

    if (widget.testingCtrl == null &&
        data.testingCharge != null &&
        data.testingCharge!.isNotEmpty) {
      _cTesting.text = data.testingCharge ?? '';
    }

    if (widget.consumablesCtrl == null &&
        data.consumables != null &&
        data.consumables!.isNotEmpty) {
      _cConsumables.text = data.consumables ?? '';
    }

    if (widget.additionalFactoryCtrl == null &&
        data.additionalChargesApartFromFactory != null &&
        data.additionalChargesApartFromFactory!.isNotEmpty) {
      _cAdditionalFactory.text = data.additionalChargesApartFromFactory ?? '';
    }

    if (widget.additionalCtrl == null &&
        data.additionalCharge != null &&
        data.additionalCharge!.isNotEmpty) {
      _cAdditional.text = data.additionalCharge ?? '';
    }

    if (widget.amcAmountCtrl == null &&
        data.amcAmount != null &&
        data.amcAmount!.isNotEmpty) {
      _cAmcAmount.text = data.amcAmount ?? '';
    }

    if (widget.quantityCtrl == null) {
      _cQuantity.text = '1';
    }

    if (widget.unitPriceCtrl == null &&
        data.unitPrice != null &&
        data.unitPrice!.isNotEmpty) {
      _cUnitPrice.text = data.unitPrice ?? '';
    }

    if (widget.companyProfitCtrl == null &&
        data.companyProfit != null &&
        data.companyProfit!.isNotEmpty) {
      _cCompanyProfit.text = data.companyProfit ?? '';
    }

    if (widget.companyProfitAmountCtrl == null &&
        data.companyProfitAmount != null &&
        data.companyProfitAmount!.isNotEmpty) {
      _cCompanyProfitAmount.text = data.companyProfitAmount ?? '';
    }

    if (widget.salesCommissionCtrl == null &&
        data.salesCommission != null &&
        data.salesCommission!.isNotEmpty) {
      _cSalesCommission.text = data.salesCommission ?? '';
    }

    if (widget.salesCommissionAmountCtrl == null &&
        data.salesCommissionAmount != null &&
        data.salesCommissionAmount!.isNotEmpty) {
      _cSalesCommissionAmount.text = data.salesCommissionAmount ?? '';
    }

    if (widget.subTotalCtrl == null &&
        data.subTotal != null &&
        data.subTotal!.isNotEmpty) {
      _cSubTotal.text = data.subTotal ?? '';
    }

    if (widget.taxPercentageCtrl == null &&
        data.taxPercentage != null &&
        data.taxPercentage!.isNotEmpty) {
      _cTaxPercentage.text = data.taxPercentage ?? '';
    }

    if (widget.taxAmountCtrl == null &&
        data.taxAmount != null &&
        data.taxAmount!.isNotEmpty) {
      _cTaxAmount.text = data.taxAmount ?? '';
    }

    if (widget.totalSalePriceCtrl == null &&
        data.totalSalePrice != null &&
        data.totalSalePrice!.isNotEmpty) {
      _cTotalSalePrice.text = data.totalSalePrice ?? '';
    }

    // ==========================================================
    // EXISTING DROPDOWN VALUES
    // ==========================================================

    if (widget.liftTypeId == null) {
      _internalLiftTypeId = _validSpecId(
        data.liftValues,
        data.liftType,
      );
    }

    if (widget.openingId == null) {
      _internalOpeningId = _validSpecId(
        data.opening,
        data.openingName,
      );
    }

    if (widget.doorOpeningId == null) {
      _internalDoorOpeningId = _validSpecId(
        data.cabinOpening,
        data.doorOpening,
      );
    }

    if (widget.cabinSideWallId == null) {
      _internalCabinSideWallId = _validSpecId(
        data.cabinSideWall,
        data.cabinSideWallName,
      );
    }

    if (widget.landingDoorId == null) {
      _internalLandingDoorId = _validSpecId(
        data.landingDoor,
        data.landingDoorName,
      );
    }

    if (widget.copId == null) {
      _internalCopId = _validSpecId(
        data.cop,
        data.copName,
      );
    }

    if (widget.lopId == null) {
      _internalLopId = _validSpecId(
        data.lop,
        data.lopName,
      );
    }

    if (widget.taxType == null) {
      _internalTaxType = data.taxType != null && data.taxType!.isNotEmpty
          ? data.taxType
          : null;
    }
  }

  String? _validSpecId(
    List<dynamic>? list,
    String? id,
  ) {
    if (list == null || id == null || id.isEmpty) {
      return null;
    }

    for (final e in list) {
      if (e is CommonValue && e.valueId == id) {
        return id;
      }

      if (e is EstimationPricingDropdownItem && e.valueId == id) {
        return id;
      }

      try {
        if (e.valueId?.toString() == id) {
          return id;
        }
      } catch (_) {}
    }

    return null;
  }

  // ============================================================
  // PRICING CALCULATION
  // ============================================================

  void _calculatePricing() {
    final factory = double.tryParse(_cFactoryPrice.text) ?? 0;

    final transportation = double.tryParse(_cTransportation.text) ?? 0;

    final installation = double.tryParse(_cInstallation.text) ?? 0;

    final testing = double.tryParse(_cTesting.text) ?? 0;

    final consumables = double.tryParse(_cConsumables.text) ?? 0;

    final additionalFactory = double.tryParse(_cAdditionalFactory.text) ?? 0;

    final additional = double.tryParse(_cAdditional.text) ?? 0;

    final amcAmount = double.tryParse(_cAmcAmount.text) ?? 0;

    double quantity = double.tryParse(_cQuantity.text) ?? 1;

    if (quantity <= 0) {
      quantity = 1;
    }

    final unitPrice = (factory +
            transportation +
            installation +
            testing +
            consumables +
            additionalFactory +
            additional +
            amcAmount) *
        quantity;

    _cUnitPrice.text = unitPrice.toStringAsFixed(2);

    final companyProfit = double.tryParse(_cCompanyProfit.text) ?? 0;

    final companyProfitAmount = unitPrice * companyProfit / 100;

    _cCompanyProfitAmount.text = companyProfitAmount.toStringAsFixed(2);

    final salesCommission = double.tryParse(_cSalesCommission.text) ?? 0;

    final salesCommissionAmount = companyProfitAmount * salesCommission / 100;

    _cSalesCommissionAmount.text = salesCommissionAmount.toStringAsFixed(2);

    final subTotal = unitPrice + companyProfitAmount + salesCommissionAmount;

    _cSubTotal.text = subTotal.toStringAsFixed(2);

    final tax = double.tryParse(_cTaxPercentage.text) ?? 0;

    final taxAmount = subTotal * tax / 100;

    _cTaxAmount.text = taxAmount.toStringAsFixed(2);

    final totalSalePrice = subTotal + taxAmount;

    _cTotalSalePrice.text = totalSalePrice.round().toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final showEstimation = widget.permissions?.data?.createEstimation == true;

    final showPricing = widget.permissions?.data?.createPricing == true;
    print(
      'PERMISSION DEBUG: '
      'permissions=${widget.permissions}, '
      'data=${widget.permissions?.data}, '
      'createEstimation=${widget.permissions?.data?.createEstimation}, '
      'createPricing=${widget.permissions?.data?.createPricing}',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showEstimation) ...[
          _buildEstimationCard(
            context,
            data,
          ),
        ],
        if (showPricing) ...[
          const SizedBox(height: 12),
          _buildPricingCard(
            context,
            data,
          ),
        ],
      ],
    );
  }

  // ============================================================
  // ESTIMATION CARD
  // ============================================================

  Widget _buildEstimationCard(
    BuildContext context,
    dynamic data,
  ) {
    final dropdownData = _estimationDropdownData;

    final liftValues =
        dropdownData?.liftValues ?? <EstimationPricingDropdownItem>[];

    final openingList =
        dropdownData?.opening ?? <EstimationPricingDropdownItem>[];

    final cabinOpeningList =
        dropdownData?.cabinOpening ?? <EstimationPricingDropdownItem>[];

    final cabinSideWallList =
        dropdownData?.cabinSideWall ?? <EstimationPricingDropdownItem>[];

    final landingDoorList =
        dropdownData?.landingDoor ?? <EstimationPricingDropdownItem>[];

    final copList = dropdownData?.cop ?? <EstimationPricingDropdownItem>[];

    final lopList = dropdownData?.lop ?? <EstimationPricingDropdownItem>[];

    return _pricingCardSection(
      title: 'Estimation & Pricing',
      icon: Icons.assignment_outlined,
      children: [
        _pricingField(
          'Subject',
          _cQuotationTitle,
          prefixIcon: Icons.title_outlined,
          hintText: 'Quotation Title',
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            // _pricingField(
            //   'Quotation',
            //   _cQuotation,
            //   prefixIcon: Icons.description_outlined,
            //   hintText: 'Home Lift',
            // ),
            _pricingField(
              'Client Name',
              _cClientName,
              prefixIcon: Icons.person_outline,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Phone',
              _cPhone,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            _pricingField(
              'Location',
              _cLocation,
              prefixIcon: Icons.location_on_outlined,
            ),
            _pricingField(
              'Elevator Type',
              _cElevatorType,
              prefixIcon: Icons.elevator_outlined,
            ),
            _pricingField(
              'Type of Opening',
              _cTypeOfOpening,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingDropdown(
              label: 'Lift Type',
              value: _liftTypeId,
              items: liftValues,
              onChanged: (v) {
                if (widget.onLiftTypeChanged != null) {
                  widget.onLiftTypeChanged!(v);
                } else {
                  setState(() {
                    _internalLiftTypeId = v;
                  });
                }
              },
            ),
            _pricingField(
              'Capacity',
              _cCapacity,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Passenger Capacity',
              _cPassengerCapacity,
              keyboardType: TextInputType.number,
              hintText: '6',
            ),
            _pricingField(
              'Shaft Width',
              _cShaftWidth,
              keyboardType: TextInputType.number,
              hintText: '1500',
            ),
            _pricingField(
              'Shaft Depth',
              _cShaftDepth,
              keyboardType: TextInputType.number,
              hintText: '1700',
            ),
            _pricingField(
              'Pit Depth',
              _cPitDepth,
              keyboardType: TextInputType.number,
              hintText: '1500',
            ),
            _pricingField(
              'Travel Height',
              _cTravelHeight,
              keyboardType: TextInputType.number,
            ),
            _pricingField(
              'Overhead Height',
              _cOverheadHeight,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingDropdown(
              label: 'Opening',
              value: _openingId,
              items: openingList,
              onChanged: (v) {
                if (widget.onOpeningChanged != null) {
                  widget.onOpeningChanged!(v);
                } else {
                  setState(() {
                    _internalOpeningId = v;
                  });
                }
              },
            ),
            _pricingDropdown(
              label: 'Door Opening',
              value: _doorOpeningId,
              items: cabinOpeningList,
              onChanged: (v) {
                if (widget.onDoorOpeningChanged != null) {
                  widget.onDoorOpeningChanged!(v);
                } else {
                  setState(() {
                    _internalDoorOpeningId = v;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingDropdown(
              label: 'Cabin (Side Wall)',
              value: _cabinSideWallId,
              items: cabinSideWallList,
              onChanged: (v) {
                if (widget.onCabinSideWallChanged != null) {
                  widget.onCabinSideWallChanged!(v);
                } else {
                  setState(() {
                    _internalCabinSideWallId = v;
                  });
                }
              },
            ),
            _pricingDropdown(
              label: 'Landing & Car Door',
              value: _landingDoorId,
              items: landingDoorList,
              onChanged: (v) {
                if (widget.onLandingDoorChanged != null) {
                  widget.onLandingDoorChanged!(v);
                } else {
                  setState(() {
                    _internalLandingDoorId = v;
                  });
                }
              },
            ),
            _pricingDropdown(
              label: 'COP',
              value: _copId,
              items: copList,
              onChanged: (v) {
                if (widget.onCopChanged != null) {
                  widget.onCopChanged!(v);
                } else {
                  setState(() {
                    _internalCopId = v;
                  });
                }
              },
            ),
            _pricingDropdown(
              label: 'LOP',
              value: _lopId,
              items: lopList,
              onChanged: (v) {
                if (widget.onLopChanged != null) {
                  widget.onLopChanged!(v);
                } else {
                  setState(() {
                    _internalLopId = v;
                  });
                }
              },
            ),
            _pricingField(
              'Warranty (Year)',
              _cWarranty,
              keyboardType: TextInputType.number,
              hintText: '5',
            ),
            _pricingField(
              'AMC (Year)',
              _cAmc,
              keyboardType: TextInputType.number,
              hintText: '1',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // PRICING CARD
  // ============================================================

  Widget _buildPricingCard(
    BuildContext context,
    dynamic data,
  ) {
    final taxTypes =
        _estimationDropdownData?.taxTypes ?? <EstimationPricingTaxType>[];

    return _pricingCardSection(
      title: 'Pricing',
      icon: Icons.payments_outlined,
      children: [
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Factory Price',
              _cFactoryPrice,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Transportation & Off Loading',
              _cTransportation,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Installation Charge',
              _cInstallation,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Testing & Commissioning',
              _cTesting,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Consumables',
              _cConsumables,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Additional Charges (Factory)',
              _cAdditionalFactory,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Additional',
              _cAdditional,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'AMC Amount',
              _cAmcAmount,
              keyboardType: TextInputType.number,
              prefixText: '₹',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Quantity',
              _cQuantity,
              readOnly: true,
              prefixText: 'x',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Unit Price',
              _cUnitPrice,
              readOnly: true,
              prefixText: '₹',
            ),
            _pricingField(
              'Company Profit (%)',
              _cCompanyProfit,
              keyboardType: TextInputType.number,
              prefixText: '%',
              onChanged: (_) => _calculatePricing(),
            ),
            _pricingField(
              'Company Profit Amount',
              _cCompanyProfitAmount,
              readOnly: true,
              prefixText: '₹',
            ),
            _pricingField(
              'Sales Commission (%)',
              _cSalesCommission,
              keyboardType: TextInputType.number,
              prefixText: '%',
              onChanged: (_) => _calculatePricing(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Sales Commission Amount',
              _cSalesCommissionAmount,
              readOnly: true,
              prefixText: '₹',
            ),
            _pricingField(
              'Sub Total',
              _cSubTotal,
              readOnly: true,
              prefixText: '₹',
            ),
            _pricingDropdown(
              label: 'Tax Type',
              value: _taxType,
              items: taxTypes,
              onChanged: (v) {
                if (widget.onTaxTypeChanged != null) {
                  widget.onTaxTypeChanged!(v);
                } else {
                  setState(() {
                    _internalTaxType = v;
                  });
                }
              },
            ),
            _pricingField(
              'Tax (%)',
              _cTaxPercentage,
              keyboardType: TextInputType.number,
              prefixText: '%',
              onChanged: (_) => _calculatePricing(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGridRow(
          context,
          [
            _pricingField(
              'Tax Amount',
              _cTaxAmount,
              readOnly: true,
              prefixText: '₹',
            ),
            _pricingField(
              'Total Sale Price',
              _cTotalSalePrice,
              keyboardType: TextInputType.number,
              prefixText: '₹',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // CARD SECTION
  // ============================================================

  Widget _pricingCardSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2a86c9).withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2a86c9).withOpacity(0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2a86c9),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E6091),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRID
  // ============================================================

  Widget _buildGridRow(
    BuildContext context,
    List<Widget> fields,
  ) {
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width < 600 ? 2 : (fields.length > 3 ? 4 : 3);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) /
            crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields.map(
            (field) {
              return SizedBox(
                width: itemWidth,
                child: field,
              );
            },
          ).toList(),
        );
      },
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _pricingField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    IconData? prefixIcon,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 16,
                    color: const Color(0xFF2a86c9),
                  )
                : (prefixText != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 4,
                          top: 11,
                          bottom: 11,
                        ),
                        child: Text(
                          prefixText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a86c9),
                          ),
                        ),
                      )
                    : null),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2a86c9),
                width: 1.8,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _pricingDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required ValueChanged<String?> onChanged,
  }) {
    String? getItemId(dynamic item) {
      if (item is CommonValue) {
        return item.valueId?.toString();
      }

      if (item is EstimationPricingDropdownItem) {
        return item.valueId;
      }

      if (item is EstimationPricingTaxType) {
        return item.id;
      }

      try {
        return item.valueId?.toString();
      } catch (_) {
        return null;
      }
    }

    String getItemName(dynamic item) {
      if (item is CommonValue) {
        return item.valueName ?? '';
      }

      if (item is EstimationPricingDropdownItem) {
        return item.valueName;
      }

      if (item is EstimationPricingTaxType) {
        return item.value;
      }

      try {
        return item.valueName?.toString() ?? '';
      } catch (_) {
        return item.toString();
      }
    }

    // Remove invalid selected value.
    final String? dropdownValue =
        items.any((item) => getItemId(item) == value) ? value : null;

    final dropdownItems = <DropdownMenuItem<String>>[];

    for (final item in items) {
      final id = getItemId(item);
      final name = getItemName(item);

      if (id != null && id.isNotEmpty) {
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: id,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                name,
                softWrap: true,
              ),
            ),
          ),
        );
      }
    }

    debugPrint(
      '$label -> items: ${dropdownItems.length}, value: $dropdownValue',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: dropdownValue,
          isExpanded: true,

          // IMPORTANT
          menuMaxHeight: 300,

          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF2A86C9),
            size: 20,
          ),

          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),

          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2A86C9),
                width: 1.8,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),

          hint: Text(
            _isLoadingEstimationDropdowns ? 'Loading...' : 'Select',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),

          items: dropdownItems,

          onChanged: dropdownItems.isEmpty
              ? null
              : (selectedValue) {
                  debugPrint(
                    '$label changed -> $selectedValue',
                  );

                  onChanged(selectedValue);
                },
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _internalQuotationTitle.dispose();
    _internalQuotation.dispose();
    _internalClientName.dispose();
    _internalPhone.dispose();
    _internalLocation.dispose();
    _internalElevatorType.dispose();
    _internalTypeOfOpening.dispose();
    _internalCapacity.dispose();
    _internalPassengerCapacity.dispose();
    _internalShaftWidth.dispose();
    _internalShaftDepth.dispose();
    _internalPitDepth.dispose();
    _internalTravelHeight.dispose();
    _internalOverheadHeight.dispose();
    _internalWarranty.dispose();
    _internalAmc.dispose();

    _internalFactoryPrice.dispose();
    _internalTransportation.dispose();
    _internalInstallation.dispose();
    _internalTesting.dispose();
    _internalConsumables.dispose();
    _internalAdditionalFactory.dispose();
    _internalAdditional.dispose();
    _internalAmcAmount.dispose();
    _internalQuantity.dispose();
    _internalUnitPrice.dispose();
    _internalCompanyProfit.dispose();
    _internalCompanyProfitAmount.dispose();
    _internalSalesCommission.dispose();
    _internalSalesCommissionAmount.dispose();
    _internalSubTotal.dispose();
    _internalTaxPercentage.dispose();
    _internalTaxAmount.dispose();
    _internalTotalSalePrice.dispose();

    super.dispose();
  }
}
