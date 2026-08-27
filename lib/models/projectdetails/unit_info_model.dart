class UnitInfoResponse {
  final List<UnitInfoData> unit;
  final String message;
  final bool status;

  UnitInfoResponse({
    required this.unit,
    required this.message,
    required this.status,
  });

  factory UnitInfoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return UnitInfoResponse(
      unit: (data['unit'] as List? ?? [])
          .map(
            (e) => UnitInfoData.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}

class UnitInfoData {
  final String id;
  final String projectId;
  final String siteLiftNo;
  final String unitMachineNo;
  final String capacity;
  final String speed;
  final String numberOfStops;
  final String numberOfOpening;
  final String travelHeight;
  final String doorSize;
  final String doorTypeId;
  final String doorModelId;
  final String machineRoomTypeId;
  final String typeId;
  final String productModelName;
  final String standardType;
  final String drawing;
  final String statusId;
  final String startDate;
  final String endDate;
  final String actualFinish;
  final String totalManpower;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String updatedBy;
  final String companyId;
  final String isDeleted;
  final String instaId;
  final String activityProjectId;
  final String unitId;
  final String methodId;
  final String activityKey;
  final String activityName;
  final String status;
  final String percentage;
  final String completedDate;
  final String methodName;
  final String roomType;
  final String modelName;
  final String unitName;
  final String siteLiftName;

  UnitInfoData({
    required this.id,
    required this.projectId,
    required this.siteLiftNo,
    required this.unitMachineNo,
    required this.capacity,
    required this.speed,
    required this.numberOfStops,
    required this.numberOfOpening,
    required this.travelHeight,
    required this.doorSize,
    required this.doorTypeId,
    required this.doorModelId,
    required this.machineRoomTypeId,
    required this.typeId,
    required this.productModelName,
    required this.standardType,
    required this.drawing,
    required this.statusId,
    required this.startDate,
    required this.endDate,
    required this.actualFinish,
    required this.totalManpower,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.companyId,
    required this.isDeleted,
    required this.instaId,
    required this.activityProjectId,
    required this.unitId,
    required this.methodId,
    required this.activityKey,
    required this.activityName,
    required this.status,
    required this.percentage,
    required this.completedDate,
    required this.methodName,
    required this.roomType,
    required this.modelName,
    required this.unitName,
    required this.siteLiftName,
  });

  factory UnitInfoData.fromJson(Map<String, dynamic> json) {
    return UnitInfoData(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      siteLiftNo: json['site_lift_no']?.toString() ?? '',
      unitMachineNo: json['unit_machine_no']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      speed: json['speed']?.toString() ?? '',
      numberOfStops: json['number_of_stops']?.toString() ?? '',
      numberOfOpening: json['number_of_opening']?.toString() ?? '',
      travelHeight: json['travel_height']?.toString() ?? '',
      doorSize: json['door_size']?.toString() ?? '',
      doorTypeId: json['door_type_id']?.toString() ?? '',
      doorModelId: json['door_model_id']?.toString() ?? '',
      machineRoomTypeId: json['machine_room_type_id']?.toString() ?? '',
      typeId: json['type_id']?.toString() ?? '',
      productModelName: json['product_model_name']?.toString() ?? '',
      standardType: json['standard_type']?.toString() ?? '',
      drawing: json['drawing']?.toString() ?? '',
      statusId: json['status_id']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      actualFinish: json['actual_finish']?.toString() ?? '',
      totalManpower: json['total_manpower']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
      instaId: json['insta_id']?.toString() ?? '',
      activityProjectId: json['activity_project_id']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      activityKey: json['activity_key']?.toString() ?? '',
      activityName: json['activity_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      percentage: json['percentage']?.toString() ?? '',
      completedDate: json['completed_date']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
      roomType: json['room_type']?.toString() ?? '',
      modelName: json['model_name']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '',
      siteLiftName: json['site_lift_name']?.toString() ?? '',
    );
  }
}
