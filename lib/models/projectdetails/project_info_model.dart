class ProjectInfoResponse {
  final ProjectInfoData data;
  final String message;
  final bool status;

  ProjectInfoResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ProjectInfoResponse.fromJson(Map<String, dynamic> json) {
    return ProjectInfoResponse(
      data: ProjectInfoData.fromJson(
        json['data'] is Map<String, dynamic> ? json['data'] : {},
      ),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}

class ProjectInfoData {
  final ProjectInfo project;
  final List<dynamic> squareFeet;
  final List<dynamic> unitCount;
  final List<dynamic> methodDetails;

  ProjectInfoData({
    required this.project,
    required this.squareFeet,
    required this.unitCount,
    required this.methodDetails,
  });

  factory ProjectInfoData.fromJson(Map<String, dynamic> json) {
    return ProjectInfoData(
      project: ProjectInfo.fromJson(
        json['project'] is Map<String, dynamic> ? json['project'] : {},
      ),
      squareFeet: json['square_feet'] is List ? json['square_feet'] : [],
      unitCount: json['unitcount'] is List ? json['unitcount'] : [],
      methodDetails:
          json['method_details'] is List ? json['method_details'] : [],
    );
  }
}

class ProjectInfo {
  final String id;
  final String clientId;
  final String custId;
  final String quotationId;
  final String leadId;
  final String projectName;
  final String projectId;
  final String projectNo;
  final String packageId;
  final String projectCategoryId;
  final String referenceNo;
  final String location;
  final String locationArea;
  final String latitude;
  final String longitude;
  final String priorityId;
  final String startingDate;
  final String completionDate;
  final String bhkNo;
  final String fixedRate;
  final String totalEstimateAmount;
  final String totalPhaseAmount;
  final String projectDescription;
  final String lpoNo;
  final String orderNo;
  final String workStatus;
  final String subStatus;
  final String isFreezed;
  final String freezeComment;
  final String isFixed;
  final String freezedDate;
  final String stateId;
  final String districtId;
  final String isPaid;
  final String isDeleted;
  final String isInstallment;
  final String companyId;
  final String branchId;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final String deletedAt;
  final String deletedBy;
  final String cctvId;
  final String assignedTo;
  final String siteMaster;
  final String status;
  final String startDate;
  final String endDate;
  final String saveToLocation;
  final String jobNumber;
  final String mainContractor;
  final String consultant;
  final String contractValue;
  final String unitPriceBreakdown;
  final String numberOfUnits;
  final String projectManager;
  final String projectEngineers;
  final String warrantyPeriod;
  final String defectsLiabilityPeriod;
  final String invoiceMilestone;
  final String methodOfInstallation;
  final String siteAddress;

  // NEW
  final String clientName;
  final String contactNo;

  ProjectInfo({
    required this.id,
    required this.clientId,
    required this.custId,
    required this.quotationId,
    required this.leadId,
    required this.projectName,
    required this.projectId,
    required this.projectNo,
    required this.packageId,
    required this.projectCategoryId,
    required this.referenceNo,
    required this.location,
    required this.locationArea,
    required this.latitude,
    required this.longitude,
    required this.priorityId,
    required this.startingDate,
    required this.completionDate,
    required this.bhkNo,
    required this.fixedRate,
    required this.totalEstimateAmount,
    required this.totalPhaseAmount,
    required this.projectDescription,
    required this.lpoNo,
    required this.orderNo,
    required this.workStatus,
    required this.subStatus,
    required this.isFreezed,
    required this.freezeComment,
    required this.isFixed,
    required this.freezedDate,
    required this.stateId,
    required this.districtId,
    required this.isPaid,
    required this.isDeleted,
    required this.isInstallment,
    required this.companyId,
    required this.branchId,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.cctvId,
    required this.assignedTo,
    required this.siteMaster,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.saveToLocation,
    required this.jobNumber,
    required this.mainContractor,
    required this.consultant,
    required this.contractValue,
    required this.unitPriceBreakdown,
    required this.numberOfUnits,
    required this.projectManager,
    required this.projectEngineers,
    required this.warrantyPeriod,
    required this.defectsLiabilityPeriod,
    required this.invoiceMilestone,
    required this.methodOfInstallation,
    required this.siteAddress,
    required this.clientName,
    required this.contactNo,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      custId: json['cust_id']?.toString() ?? '',
      quotationId: json['quotation_id']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      projectNo: json['project_no']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? '',
      projectCategoryId: json['project_category_id']?.toString() ?? '',
      referenceNo: json['reference_no']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      locationArea: json['location_area']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',

      // Backend key is "longtitude"
      longitude:
          json['longtitude']?.toString() ?? json['longitude']?.toString() ?? '',

      priorityId: json['priority_id']?.toString() ?? '',
      startingDate: json['starting_date']?.toString() ?? '',
      completionDate: json['completion_date']?.toString() ?? '',
      bhkNo: json['bhk_no']?.toString() ?? '',
      fixedRate: json['fixed_rate']?.toString() ?? '',
      totalEstimateAmount: json['total_estimate_amount']?.toString() ?? '',
      totalPhaseAmount: json['total_phase_amount']?.toString() ?? '',
      projectDescription: json['project_description']?.toString() ?? '',
      lpoNo: json['lpo_no']?.toString() ?? '',
      orderNo: json['order_no']?.toString() ?? '',
      workStatus: json['work_status']?.toString() ?? '',
      subStatus: json['sub_status']?.toString() ?? '',
      isFreezed: json['is_freezed']?.toString() ?? '',
      freezeComment: json['freeze_comment']?.toString() ?? '',
      isFixed: json['is_fixed']?.toString() ?? '',
      freezedDate: json['freezed_date']?.toString() ?? '',
      stateId: json['state_id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      isPaid: json['is_paid']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
      isInstallment: json['is_installment']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString() ?? '',
      deletedBy: json['deleted_by']?.toString() ?? '',
      cctvId: json['cctv_id']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      siteMaster: json['site_master']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      saveToLocation: json['save_to_location']?.toString() ?? '',
      jobNumber: json['job_number']?.toString() ?? '',
      mainContractor: json['main_contractor']?.toString() ?? '',
      consultant: json['consultant']?.toString() ?? '',
      contractValue: json['contract_value']?.toString() ?? '',
      unitPriceBreakdown: json['unit_price_breakdown']?.toString() ?? '',
      numberOfUnits: json['number_of_units']?.toString() ?? '',
      projectManager: json['project_manager']?.toString() ?? '',
      projectEngineers: json['project_engineers']?.toString() ?? '',
      warrantyPeriod: json['warranty_period']?.toString() ?? '',
      defectsLiabilityPeriod:
          json['defects_liability_period']?.toString() ?? '',
      invoiceMilestone: json['invoice_milestone']?.toString() ?? '',
      methodOfInstallation: json['method_of_installation']?.toString() ?? '',
      siteAddress: json['site_address']?.toString() ?? '',

      // NEW
      clientName: json['client_name']?.toString() ?? '',
      contactNo: json['contact_no']?.toString() ?? '',
    );
  }
}
