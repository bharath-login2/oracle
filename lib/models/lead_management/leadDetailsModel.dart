class LeadDeatailsModel {
  Data? data;
  bool? status;
  String? message;

  LeadDeatailsModel({this.data, this.status, this.message});

  LeadDeatailsModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }
}

class Data {
  String? callMasterId;
  String? leadCategoryId;
  String? leadSubCategoryId;
  String? clientName;
  String? address;
  String? cost;
  String? assignedUserId;
  String? callResultId;
  String? calledDate;
  String? createdDate;
  String? createdStaff;
  String? nextFollowupDate;
  String? remarks;
  String? leadMethod;
  String? leadCategory;
  String? leadSubCategory;
  String? callResult;
  String? staffName;
  String? priorityId;
  String? priority;
  String? countryCode;
  String? contactNumber1;
  String? branchId;
  bool? callHistoryPermission;
  bool? fileManagerPermission;
  List<LeadCategories>? leadCategories;
  List<Calleddata>? calleddata;
  bool? callPermission;
  String? warningMessage;
  String? callLeadId;
  String? leadSource;
  String? leadSourceId;
  String? postOffice;
  String? pinCode;
  String? stateId;
  String? districtId;
  String? stateName;
  String? districtName;
  String? productsOnAdd;
  String? whatsaAppNumber;
  String? emailId;
  String? whatsappNumber;
  String? email;
  String? products;
  String? state;
  String? district;
  String? whatsappNumberCountryCode;
  List<CallHandledUsers>? callHandledUsers;
bool? createPricingDetails;
bool? createEstimation;
bool? createPricing;
bool? sendQuoteRequest;

List<CommonValue>? taxTypes;
List<CommonValue>? liftValues;
List<CommonValue>? opening;
List<CommonValue>? cabinOpening;
List<CommonValue>? cabinSideWall;
List<CommonValue>? landingDoor;
List<CommonValue>? cop;
List<CommonValue>? lop;
// Estimation
String? quotation;
String? location;
String? elevatorType;
String? typeOfOpening;
String? liftType;
String? capacity;
String? passengerCapacity;
String? shaftWidth;
String? shaftDepth;
String? pitDepth;
String? travelHeight;
String? overheadHeight;
String? openingName;
String? doorOpening;
String? cabinSideWallName;
String? landingDoorName;
String? copName;
String? lopName;

// Pricing
String? warranty;
String? amc;
String? factoryPrice;
String? transportationCharge;
String? installationCharge;
String? testingCharge;
String? consumables;
String? additionalChargesApartFromFactory;
String? additionalCharge;
String? quantity;
String? unitPrice;
String? companyProfit;
String? companyProfitAmount;
String? salesCommission;
String? salesCommissionAmount;
String? subTotal;
String? taxType;
String? taxPercentage;
String? taxAmount;
String? totalSalePrice;
  Data({
    this.callMasterId,
    this.leadCategoryId,
    this.leadSubCategoryId,
    this.clientName,
    this.address,
    this.cost,
    this.assignedUserId,
    this.callResultId,
    this.calledDate,
    this.createdDate,
    this.createdStaff,
    this.nextFollowupDate,
    this.remarks,
    this.leadMethod,
    this.leadCategory,
    this.leadSubCategory,
    this.callResult,
    this.staffName,
    this.priorityId,
    this.priority,
    this.countryCode,
    this.contactNumber1,
    this.branchId,
    this.callHistoryPermission,
    this.fileManagerPermission,
    this.leadCategories,
    this.callPermission,
    this.warningMessage,
    this.callLeadId,
    this.leadSource,
    this.leadSourceId,
    this.postOffice,
    this.pinCode,
    this.stateId,
    this.districtId,
    this.stateName,
    this.districtName,
    this.productsOnAdd,
    this.whatsaAppNumber,
    this.emailId,
    this.whatsappNumber,
    this.email,
    this.products,
    this.state,
    this.district,
    this.whatsappNumberCountryCode,
    this.callHandledUsers,
    this.createPricingDetails,
this.createEstimation,
this.createPricing,
this.sendQuoteRequest,
this.taxTypes,
this.liftValues,
this.opening,
this.cabinOpening,
this.cabinSideWall,
this.landingDoor,
this.cop,
this.lop,
this.quotation,
this.location,
this.elevatorType,
this.typeOfOpening,
this.liftType,
this.capacity,
this.passengerCapacity,
this.shaftWidth,
this.shaftDepth,
this.pitDepth,
this.travelHeight,
this.overheadHeight,
this.openingName,
this.doorOpening,
this.cabinSideWallName,
this.landingDoorName,
this.copName,
this.lopName,

this.warranty,
this.amc,
this.factoryPrice,
this.transportationCharge,
this.installationCharge,
this.testingCharge,
this.consumables,
this.additionalChargesApartFromFactory,
this.additionalCharge,
this.quantity,
this.unitPrice,
this.companyProfit,
this.companyProfitAmount,
this.salesCommission,
this.salesCommissionAmount,
this.subTotal,
this.taxType,
this.taxPercentage,
this.taxAmount,
this.totalSalePrice,
  });

  Data.fromJson(Map<String, dynamic> json) {
    callMasterId = json['call_master_id'] ?? "";
    leadCategoryId = json['lead_category_id'] ?? "";
    leadSubCategoryId = json['lead_sub_category_id'] ?? "";
    clientName = json['client_name'] ?? "";
    address = json['address'] ?? "";
    cost = json['cost'] ?? "";
    assignedUserId = json['assigned_user_id'] ?? "";
    callResultId =
        (json['call_result_id'] ?? json['call_response_id'] ?? "").toString();
    calledDate = json['called_date'] ?? "";
    createdStaff = json['created_staff'] ?? "";
    createdDate = json['created_date'] ?? "";
    nextFollowupDate = json['next_followup_date'] ?? "";
    remarks = json['remarks'] ?? "";
    leadMethod = json['lead_method'] ?? "";
    leadCategory = json['lead_category'] ?? "";
    leadSubCategory = json['lead_sub_category'] ?? "";
    callResult = json['call_result'] ?? json['call_response'] ?? "";
    staffName = json['staff_name'] ?? "";
    priorityId = json['priority_id'] ?? "";
    priority = json['priority'] ?? "";
    countryCode = json['country_code'] ?? "";
    contactNumber1 = json['contact_number1'] ?? "";
    branchId = json['branch_id'] ?? "";
    callHistoryPermission = json['callHistoryPermission'];
    fileManagerPermission = json['fileManagerPermission'];
    createPricingDetails = json['createPricingDetails'] ?? false;
    final pricing = json['leadPricing'] ?? {};
final specs = json['leadPricingSpecs'] ?? {};
createEstimation = json['createEstimation'] ?? false;
createPricing = json['createPricing'] ?? false;
sendQuoteRequest = json['sendQuoteRequest'] ?? false;

if (json['tax_types'] != null) {
  taxTypes = <CommonValue>[];
  json['tax_types'].forEach((v) {
    taxTypes!.add(CommonValue.fromJson(v));
  });
}

if (json['lift_values'] != null) {
  liftValues = <CommonValue>[];
  json['lift_values'].forEach((v) {
    liftValues!.add(CommonValue.fromJson(v));
  });
}

if (json['opening'] != null) {
  opening = <CommonValue>[];
  json['opening'].forEach((v) {
    opening!.add(CommonValue.fromJson(v));
  });
}

if (json['cabin_opening'] != null) {
  cabinOpening = <CommonValue>[];
  json['cabin_opening'].forEach((v) {
    cabinOpening!.add(CommonValue.fromJson(v));
  });
}

if (json['cabin_side_wall'] != null) {
  cabinSideWall = <CommonValue>[];
  json['cabin_side_wall'].forEach((v) {
    cabinSideWall!.add(CommonValue.fromJson(v));
  });
}

if (json['landing_door'] != null) {
  landingDoor = <CommonValue>[];
  json['landing_door'].forEach((v) {
    landingDoor!.add(CommonValue.fromJson(v));
  });
}

if (json['cop'] != null) {
  cop = <CommonValue>[];
  json['cop'].forEach((v) {
    cop!.add(CommonValue.fromJson(v));
  });
}

if (json['lop'] != null) {
  lop = <CommonValue>[];
  json['lop'].forEach((v) {
    lop!.add(CommonValue.fromJson(v));
  });
}
    if (json['leadCategories'] != null) {
      leadCategories = <LeadCategories>[];
      json['leadCategories'].forEach((v) {
        leadCategories!.add(LeadCategories.fromJson(v));
      });
    }
    if (json['calleddata'] != null) {
      calleddata = <Calleddata>[];
      json['calleddata'].forEach((v) {
        calleddata!.add(Calleddata.fromJson(v));
      });
    }

    if (json['call_handled_users'] != null) {
      callHandledUsers = <CallHandledUsers>[];
      json['call_handled_users'].forEach((v) {
        callHandledUsers!.add(CallHandledUsers.fromJson(v));
      });
    }

    callPermission = json['callPermission'];
    warningMessage = json['warningMessage'] ?? "";
    callLeadId = json['callLeadId'] ?? "";
    leadSource = json['lead_source'] ?? "";
    leadSourceId = json['lead_source_id'] ?? "";
    postOffice = json['post_office'] ?? "";
    pinCode = json['pincode'] ?? "";
    stateId = json['state_id'] ?? "";
    districtId = json['district_id'] ?? "";
    stateName = json['state_name'] ?? "";
    districtName = json['district_name'] ?? "";
    productsOnAdd = json['products_lead'] ?? "";
    whatsaAppNumber = json['whatsapp_number_lead'] ?? "";
    emailId = json['email_lead'] ?? "";
    whatsappNumber = json['whatsapp_number'] ?? "";
    email = json['email'] ?? "";
    products = json['products'] ?? "";
    state = json['state'] ?? "";
    district = json['district'] ?? "";
    whatsappNumberCountryCode = json['whatsapp_country_code'] ?? "";
    quotation = pricing['quotation_name'] ?? "";
location = pricing['location'] ?? "";
elevatorType = pricing['elevator_type'] ?? "";
typeOfOpening = pricing['type_of_opening'] ?? "";
passengerCapacity = pricing['no_of_passenger'] ?? "";
liftType = specs['lift_type'] ?? "";
openingName = specs['opening_type'] ?? "";
doorOpening = specs['door_opening'] ?? "";
cabinSideWallName = specs['cabin_side_wall'] ?? "";
landingDoorName = specs['landing_door'] ?? "";
copName = specs['cop'] ?? "";
lopName = specs['lop'] ?? "";

capacity = specs['lift_capacity'] ?? "";
shaftWidth = specs['shaft_width'] ?? "";
shaftDepth = specs['shaft_depth'] ?? "";
pitDepth = specs['pit_depth'] ?? "";
travelHeight = specs['travel_height'] ?? "";
overheadHeight = specs['over_head_height'] ?? "";
warranty = pricing['wr'] ?? "";
amc = pricing['amc'] ?? "";
factoryPrice = pricing['factory_price'] ?? "";
transportationCharge = pricing['transportation'] ?? "";
installationCharge = pricing['installation_charge'] ?? "";
testingCharge = pricing['testing_commissioning'] ?? "";
consumables = pricing['consumables'] ?? "";
additionalChargesApartFromFactory =
    pricing['additional_factory_charges'] ?? "";
additionalCharge = pricing['additional_amount'] ?? "";

unitPrice = pricing['price'] ?? "";
taxType = pricing['tax_type'] ?? "";
taxPercentage = pricing['tax'] ?? "";
taxAmount = pricing['tax_amount'] ?? "";
companyProfit = pricing['comp_profit'] ?? "";
companyProfitAmount = pricing['comp_profit_amount'] ?? "";
salesCommission = pricing['sales_commission'] ?? "";
salesCommissionAmount = pricing['sales_commission_amount'] ?? "";
subTotal = pricing['sub_total'] ?? "";
totalSalePrice = pricing['grand_total'] ?? "";
  }
}

class CommonValue {
  String? valueId;
  String? valueName;

  CommonValue({
    this.valueId,
    this.valueName,
  });

  CommonValue.fromJson(Map<String, dynamic> json) {
    valueId = (json['value_id'] ?? json['id'] ?? '').toString();
    valueName = (json['value_name'] ?? json['value'] ?? '').toString();
  }
}
class LeadCategories {
  String? callMasterId;
  String? leadCategoryId;
  String? leadCategory;
  String? leadSubCategory;
  String? createdDate;
  String? leadStatus;
  String? staffName;
  bool? isSelected;

  LeadCategories(
      {this.callMasterId,
      this.leadCategoryId,
      this.leadCategory,
      this.leadSubCategory,
      this.createdDate,
      this.leadStatus,
      this.staffName,
      this.isSelected});

  LeadCategories.fromJson(Map<String, dynamic> json) {
    callMasterId = json['call_master_id'];
    leadCategoryId = json['lead_category_id'];
    leadCategory = json['lead_category'];
    leadSubCategory = json['lead_sub_category'];
    createdDate = json['created_date'];
    leadStatus = json['lead_status'];
    staffName = json['staff_name'];
    isSelected = json['is_selected'];
  }
}

class Calleddata {
  String? name;
  String? phoneNum;
  String? callType;
  String? durationTime;
  String? simName;
  String? dateTime;
  String? formatteddateTime;
  String? companyName;
  String? proPic;
  String? formattedDuration;

  Calleddata(
      {this.name,
      this.phoneNum,
      this.callType,
      this.durationTime,
      this.simName,
      this.dateTime,
      this.formatteddateTime,
      this.companyName,
      this.proPic,
      this.formattedDuration});

  Calleddata.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    phoneNum = json['phone_number'] ?? "";
    callType = json['callType'] ?? "";
    durationTime = json['duration'] ?? "";
    simName = json['SimName'] ?? "";
    dateTime = json['date_time'] ?? "";
    formatteddateTime = json['formatted_date_time'] ?? "";
    companyName = json['company_name'] ?? "";
    proPic = json['pro_pic'] ?? "";
    formattedDuration = json['formatted_duration'] ?? "";
  }
}

class CallHandledUsers {
  String? userId;
  String? staffName;
  String? proPicThumb;
  String? phoneNo;
  String? email;
  String? callCount;

  CallHandledUsers({
    this.userId,
    this.staffName,
    this.proPicThumb,
    this.phoneNo,
    this.email,
    this.callCount,
  });

  CallHandledUsers.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? "";
    staffName = json['staff_name'] ?? "";
    proPicThumb = json['pro_pic_thumb'] ?? "";
    phoneNo = json['phone_no'] ?? "";
    email = json['email'] ?? "";
    callCount = json['call_count'] ?? "";
  }
}
