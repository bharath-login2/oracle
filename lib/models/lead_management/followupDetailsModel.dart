class FollowupDetailsModel {
  bool? status;
  String? message;
  Data? data;

  FollowupDetailsModel({this.status, this.message, this.data});

  FollowupDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? callDetailsId;
  String? callMasterId;
  String? cost;
  String? leadCategoryId;
  String? leadCategory;
  String? leadSubCategoryId;
  String? leadSubCategory;
  String? calledDate;
  String? callResultId;
  String? callResult;
  String? callResponseId;
  String? callResponse;
  String? followupDate;
  String? remarks;
  String? reason;
  String? reasonId;
  List<AdditionalField>? additionalFields;

  // Additional Estimation & AMC fields returned by get_lead_followup_details
  String? amcType;
  String? liftBrand;
  String? ageOfLift;
  String? subject;
  String? passengerCapacity;
  String? amcPrice;
  String? quotationTitle;
  String? clientName;
  String? phone;
  String? location;
  String? elevatorType;
  String? typeOfOpening;
  String? noOfPassenger;
  String? wr;
  String? amc;
  String? factoryPrice;
  String? transportation;
  String? installationCharge;
  String? testingCommissioning;
  String? consumables;
  String? additionalFactoryCharges;
  String? additionalAmount;
  String? amcAmount;
  String? price;
  String? compProfit;
  String? compProfitAmount;
  String? salesCommission;
  String? salesCommissionAmount;
  String? subTotal;
  String? taxType;
  String? tax;
  String? taxAmount;
  String? grandTotal;
  String? liftType;
  String? openingType;
  String? doorOpening;
  String? cabinSideWall;
  String? landingDoor;
  String? cop;
  String? lop;
  String? liftCapacity;
  String? shaftWidth;
  String? shaftDepth;
  String? pitDepth;
  String? travelHeight;
  String? overHeadHeight;
  String? doorOpeningSize;

  Data(
      {this.callDetailsId,
      this.callMasterId,
      this.cost,
      this.leadCategoryId,
      this.leadCategory,
      this.leadSubCategoryId,
      this.leadSubCategory,
      this.calledDate,
      this.callResultId,
      this.callResult,
      this.callResponseId,
      this.callResponse,
      this.followupDate,
      this.remarks,
      this.reason,
      this.reasonId,
      this.additionalFields,
      this.amcType,
      this.liftBrand,
      this.ageOfLift,
      this.subject,
      this.passengerCapacity,
      this.amcPrice,
      this.quotationTitle,
      this.clientName,
      this.phone,
      this.location,
      this.elevatorType,
      this.typeOfOpening,
      this.noOfPassenger,
      this.wr,
      this.amc,
      this.factoryPrice,
      this.transportation,
      this.installationCharge,
      this.testingCommissioning,
      this.consumables,
      this.additionalFactoryCharges,
      this.additionalAmount,
      this.amcAmount,
      this.price,
      this.compProfit,
      this.compProfitAmount,
      this.salesCommission,
      this.salesCommissionAmount,
      this.subTotal,
      this.taxType,
      this.tax,
      this.taxAmount,
      this.grandTotal,
      this.liftType,
      this.openingType,
      this.doorOpening,
      this.cabinSideWall,
      this.landingDoor,
      this.cop,
      this.lop,
      this.liftCapacity,
      this.shaftWidth,
      this.shaftDepth,
      this.pitDepth,
      this.travelHeight,
      this.overHeadHeight,
      this.doorOpeningSize});

  Data.fromJson(Map<String, dynamic> json) {
    callDetailsId = json['call_details_id']?.toString() ?? "";
    callMasterId = json['call_master_id']?.toString() ?? "";
    cost = json['cost']?.toString() ?? "";
    leadCategoryId = json['lead_category_id']?.toString() ?? "";
    leadCategory = json['lead_category']?.toString() ?? "";
    leadSubCategoryId = json['lead_sub_category_id']?.toString();
    leadSubCategory = json['lead_sub_category']?.toString();
    calledDate = json['called_date']?.toString();
    callResultId = json['call_result_id']?.toString();
    callResult = json['call_result']?.toString();
    callResponseId = json['call_response_id']?.toString();
    callResponse = json['call_response']?.toString();
    followupDate = json['followup_date']?.toString();
    remarks = json['remarks']?.toString();
    reason = json['reason']?.toString();
    reasonId = json['reason_id']?.toString();
    if (json['additional_fields'] != null) {
      additionalFields = <AdditionalField>[];
      json['additional_fields'].forEach((v) {
        additionalFields!.add(AdditionalField.fromJson(v));
      });
    }

    amcType = json['amc_type']?.toString();
    liftBrand = json['lift_brand']?.toString();
    ageOfLift = json['age_of_lift']?.toString();
    subject = json['subject']?.toString();
    passengerCapacity = json['passenger_capacity']?.toString() ?? json['no_of_passenger']?.toString();
    amcPrice = json['amc_price']?.toString() ?? json['amc_amount']?.toString();
    quotationTitle = json['quotation_title']?.toString() ?? json['subject']?.toString();
    clientName = json['client_name']?.toString();
    phone = json['phone']?.toString();
    location = json['location']?.toString();
    elevatorType = json['elevator_type']?.toString() ?? json['lift_brand']?.toString();
    typeOfOpening = json['type_of_opening']?.toString();
    noOfPassenger = json['no_of_passenger']?.toString() ?? json['passenger_capacity']?.toString();
    wr = json['wr']?.toString() ?? json['age_of_lift']?.toString();
    amc = json['amc']?.toString() ?? json['amc_type']?.toString();
    factoryPrice = json['factory_price']?.toString();
    transportation = json['transportation']?.toString();
    installationCharge = json['installation_charge']?.toString();
    testingCommissioning = json['testing_commissioning']?.toString();
    consumables = json['consumables']?.toString();
    additionalFactoryCharges = json['additional_factory_charges']?.toString();
    additionalAmount = json['additional_amount']?.toString();
    amcAmount = json['amc_amount']?.toString() ?? json['amc_price']?.toString();
    price = json['price']?.toString();
    compProfit = json['comp_profit']?.toString();
    compProfitAmount = json['comp_profit_amount']?.toString();
    salesCommission = json['sales_commission']?.toString();
    salesCommissionAmount = json['sales_commission_amount']?.toString();
    subTotal = json['sub_total']?.toString();
    taxType = json['tax_type']?.toString();
    tax = json['tax']?.toString();
    taxAmount = json['tax_amount']?.toString();
    grandTotal = json['grand_total']?.toString();
    liftType = json['lift_type']?.toString();
    openingType = json['opening_type']?.toString();
    doorOpening = json['door_opening']?.toString();
    cabinSideWall = json['cabin_side_wall']?.toString();
    landingDoor = json['landing_door']?.toString();
    cop = json['cop']?.toString();
    lop = json['lop']?.toString();
    liftCapacity = json['lift_capacity']?.toString();
    shaftWidth = json['shaft_width']?.toString();
    shaftDepth = json['shaft_depth']?.toString();
    pitDepth = json['pit_depth']?.toString();
    travelHeight = json['travel_height']?.toString();
    overHeadHeight = json['over_head_height']?.toString();
    doorOpeningSize = json['door_opening_size']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_details_id'] = callDetailsId;
    data['call_master_id'] = callMasterId;
    data['cost'] = cost;
    data['lead_category_id'] = leadCategoryId;
    data['lead_category'] = leadCategory;
    data['lead_sub_category_id'] = leadSubCategoryId;
    data['lead_sub_category'] = leadSubCategory;
    data['called_date'] = calledDate;
    data['call_result_id'] = callResultId;
    data['call_result'] = callResult;
    data['call_response_id'] = callResponseId;
    data['call_response'] = callResponse;
    data['followup_date'] = followupDate;
    data['remarks'] = remarks;
    data['reason'] = reason;
    data['reason_id'] = reasonId;
    if (additionalFields != null) {
      data['additional_fields'] =
          additionalFields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AdditionalField {
  String? id;
  String? name;
  String? value;

  AdditionalField({this.id, this.name, this.value});

  AdditionalField.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}
