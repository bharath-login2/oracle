class EstimationPricingDropdownItem {
  final String valueId;
  final String valueName;

  EstimationPricingDropdownItem({
    required this.valueId,
    required this.valueName,
  });

  factory EstimationPricingDropdownItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return EstimationPricingDropdownItem(
      valueId: json['value_id']?.toString() ?? '',
      valueName: json['value_name']?.toString() ?? '',
    );
  }
}

class EstimationPricingTaxType {
  final String id;
  final String value;

  EstimationPricingTaxType({
    required this.id,
    required this.value,
  });

  factory EstimationPricingTaxType.fromJson(
    Map<String, dynamic> json,
  ) {
    return EstimationPricingTaxType(
      id: json['id']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class EstimationPricingDropdownData {
  final List<EstimationPricingTaxType> taxTypes;
  final List<EstimationPricingDropdownItem> liftValues;
  final List<EstimationPricingDropdownItem> opening;
  final List<EstimationPricingDropdownItem> cabinOpening;
  final List<EstimationPricingDropdownItem> cabinSideWall;
  final List<EstimationPricingDropdownItem> landingDoor;
  final List<EstimationPricingDropdownItem> cop;
  final List<EstimationPricingDropdownItem> lop;

  EstimationPricingDropdownData({
    required this.taxTypes,
    required this.liftValues,
    required this.opening,
    required this.cabinOpening,
    required this.cabinSideWall,
    required this.landingDoor,
    required this.cop,
    required this.lop,
  });

  factory EstimationPricingDropdownData.fromJson(
    Map<String, dynamic> json,
  ) {
    return EstimationPricingDropdownData(
      taxTypes: (json['tax_types'] as List? ?? [])
          .map(
            (e) => EstimationPricingTaxType.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      liftValues: (json['lift_values'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      opening: (json['opening'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      cabinOpening: (json['cabin_opening'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      cabinSideWall: (json['cabin_side_wall'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      landingDoor: (json['landing_door'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      cop: (json['cop'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      lop: (json['lop'] as List? ?? [])
          .map(
            (e) => EstimationPricingDropdownItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}
