class UnitDropdownItem {
  final String id;
  final String name;

  const UnitDropdownItem({
    required this.id,
    required this.name,
  });

  factory UnitDropdownItem.fromJson(
    Map<String, dynamic> json, {
    required String idKey,
    required String nameKey,
  }) {
    return UnitDropdownItem(
      id: json[idKey]?.toString() ?? '',
      name: json[nameKey]?.toString() ?? '',
    );
  }
}

class UnitDropdownResponse {
  final List<UnitDropdownItem> liftSpeed;
  final List<UnitDropdownItem> noOfStops;
  final List<UnitDropdownItem> noOfOpening;
  final List<UnitDropdownItem> doorType;
  final List<UnitDropdownItem> liftType;
  final List<UnitDropdownItem> doorModel;
  final List<UnitDropdownItem> machineRoomTypes;
  final List<UnitDropdownItem> currentStatuses;

  final String message;
  final bool status;

  UnitDropdownResponse({
    required this.liftSpeed,
    required this.noOfStops,
    required this.noOfOpening,
    required this.doorType,
    required this.liftType,
    required this.doorModel,
    required this.machineRoomTypes,
    required this.currentStatuses,
    required this.message,
    required this.status,
  });

  factory UnitDropdownResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return UnitDropdownResponse(
      liftSpeed: _parseList(
        data['lift_speed'],
        idKey: 'value_id',
        nameKey: 'value_name',
      ),
      noOfStops: _parseList(
        data['no_of_stops'],
        idKey: 'value_id',
        nameKey: 'value_name',
      ),
      noOfOpening: _parseList(
        data['no_of_opening'],
        idKey: 'value_id',
        nameKey: 'value_name',
      ),
      doorType: _parseList(
        data['door_type'],
        idKey: 'value_id',
        nameKey: 'value_name',
      ),
      liftType: _parseList(
        data['lift_type'],
        idKey: 'value_id',
        nameKey: 'value_name',
      ),
      doorModel: _parseList(
        data['door_model'],
        idKey: 'door_model_id',
        nameKey: 'model_name',
      ),
      machineRoomTypes: _parseList(
        data['machine_room_types'],
        idKey: 'machine_room_type_id',
        nameKey: 'type_name',
      ),
      currentStatuses: _parseList(
        data['current_statuses'],
        idKey: 'id',
        nameKey: 'status_type',
      ),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }

  static List<UnitDropdownItem> _parseList(
    dynamic value, {
    required String idKey,
    required String nameKey,
  }) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (e) => UnitDropdownItem.fromJson(
            e as Map<String, dynamic>,
            idKey: idKey,
            nameKey: nameKey,
          ),
        )
        .toList();
  }
}
