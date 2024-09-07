import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/deleteMainClientModel.dart';
import 'package:login2/models/clients/is_customer_exist.dart';
import 'package:login2/models/clients/receiptDeleteModel.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/expense/exp_category_list.dart';
import 'package:login2/models/expense/exp_history.dart';
import 'package:login2/models/expense/exp_list.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/models/lead_management/addMileStoneModel.dart';
import 'package:login2/models/lead_management/fileManagerPermissionModel.dart';
import 'package:login2/models/lead_management/staff_dashboard_model.dart';
import 'package:login2/models/officialWhatsapp/campaigns_official_message_model.dart';
import 'package:login2/models/officialWhatsapp/campaign_sample_model.dart';
import 'package:login2/models/officialWhatsapp/message_view_status.dart';
import 'package:login2/models/product_mannagement/delete_category.dart';
import 'package:login2/models/product_mannagement/delete_product.dart';
import 'package:login2/models/product_mannagement/delete_subcategory.dart';
import 'package:login2/models/product_mannagement/post_category_model.dart';
import 'package:login2/models/product_mannagement/post_product.dart';
import 'package:login2/models/product_mannagement/post_subcategory.dart';
import 'package:login2/models/product_mannagement/product_categories.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/models/product_mannagement/products_by_id_model.dart';
import 'package:login2/models/product_mannagement/sub_categories.dart';
import 'package:login2/models/product_mannagement/update_product.dart';
import 'package:login2/models/product_mannagement/update_subcategory.dart';
import 'package:login2/models/renewal/add_customer_model.dart';
import 'package:login2/models/renewal/bulk_remind.dart';
import 'package:login2/models/renewal/delete_renewal.dart';
import 'package:login2/models/renewal/renewal_by_id_model.dart';
import 'package:login2/models/renewal/hidden_list.dart';
import 'package:login2/models/renewal/hide_model.dart';
import 'package:login2/models/renewal/payment_report.dart';
import 'package:login2/models/renewal/post_reminder.dart';
import 'package:login2/models/renewal/post_renewal.dart';
import 'package:login2/models/renewal/reminder_history_model.dart';
import 'package:login2/models/renewal/renewal_dashboard_model.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/models/renewal/renewal_followup_details.dart';
import 'package:login2/models/renewal/renewal_list.dart';
import 'package:login2/models/renewal/rivert_client.dart';
import 'package:login2/models/search/search.dart';
import 'package:login2/models/staff_report/staff_call_details_model.dart';
import 'package:login2/models/staff_report/staff_details_model.dart';
import 'package:login2/models/userManagement/editUserBasicDetailsModel.dart';
import 'package:login2/models/renewal/renewal_template_model.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/commonsettingsModel.dart';
import '../../models/contactGroup/addContactGroupModel.dart';
import '../../models/contactGroup/addContactNumberModel.dart';
import '../../models/contactGroup/contactFGroupModel.dart';
import '../../models/contactGroup/contactGroupDeatailsModel.dart';
import '../../models/contactGroup/deleteContactNumberModel.dart';
import '../../models/contactGroup/deleteContatGroupModel.dart';
import '../../models/contactGroup/editContactGroupModel.dart';
import '../../models/contactGroup/editContactNumberModel.dart';
import '../../models/contactGroup/groupInfoModel.dart';
import '../../models/contactGroup/sendMessageModel.dart';
import '../../models/dashboardModel.dart';
import '../../models/lead_management/addLeadCategoryModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/addLeadModel.dart';
import '../../models/lead_management/callHistoryModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/deleteLeadFollowupModel.dart';
import '../../models/lead_management/deleteLeadModel.dart';
import '../../models/lead_management/editDesignationDetailsModel.dart';
import '../../models/lead_management/editLeadCategoryModel.dart';
import '../../models/lead_management/editLeadFollowupModel.dart';
import '../../models/lead_management/editLeadModel.dart';
import '../../models/lead_management/followupDetailsModel.dart';
import '../../models/lead_management/leadCategoryDeleteModel.dart';
import '../../models/lead_management/leadDashboardModel.dart';
import '../../models/lead_management/leadDeatailsModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart';
import '../../models/lead_management/leadTransferModel.dart';
import '../../models/lead_management/searchModel.dart';
import '../../models/lead_management/viewLeadCategoryModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../../models/loginCheckModel.dart';
import '../../models/loginModel.dart';
import '../../models/sendOtpModel.dart';
import '../../models/settings/addWhatsappSettingsModel.dart';
import '../../models/settings/addWhatsappSettingsOffModel.dart';
import '../../models/settings/whatsappSettings%20MOdel.dart';
import '../../models/updateModel.dart';
import '../../models/userChangePassword.dart';
import '../../models/userManagement/addUserCommonDataModel.dart';
import '../../models/userManagement/addUserImageModel.dart';
import '../../models/userManagement/addUserModel.dart';
import '../../models/userManagement/changePasswordModel.dart';
import '../../models/userManagement/deleteStaffModel.dart';
import '../../models/userManagement/designationListModel.dart';
import '../../models/userManagement/menuModel.dart';
import '../../models/userManagement/postEditSubmenuModel.dart';
import '../../models/userManagement/postSubmenuModel.dart';
import '../../models/userManagement/viewStaffModel.dart';
import 'package:dio/dio.dart';
import '../core/common.dart';
import '../core/config.dart';
import '../models/backgroundModel.dart';
import '../models/callLogUploadPermissionModel.dart';
import '../models/callLogs/callLogHistoryModel.dart';
import '../models/callLogs/callLogUploadModel.dart';
import '../models/callLogs/callLogUploadPermissionUpdateModel.dart';
import '../models/callLogs/deleteCallHistoryModel.dart';
import '../models/clients/addClientsModel.dart';
import '../models/clients/addInvoiceCheckModel.dart';
import '../models/clients/addInvoiceModel.dart';
import '../models/clients/branchListModel.dart';
import '../models/clients/customerListModel.dart';
import '../models/clients/deleteInvoiceModel.dart';
import '../models/clients/editClientDetailsModel.dart';
import '../models/clients/editClientsModel.dart';
import '../models/clients/editInvoiceDetailsModel.dart';
import '../models/clients/editInvoiceModel.dart';
import '../models/clients/editReceiptDetailsModel.dart';
import '../models/clients/editReceiptModel.dart';
import '../models/clients/getInvoiceSearchData.dart';
import '../models/clients/invoiceListModel.dart';
import '../models/clients/ivoiceAddCommonDetailsModel.dart';
import '../models/clients/leadConvertToClientModel.dart';
import '../models/clients/mainClientDetailsModel.dart';
import '../models/clients/mainClientListModel.dart';
import '../models/clients/pendingInvoiceListModel.dart';
import '../models/clients/postalCodeModel.dart';
import '../models/clients/receiptAddCommonDetailsModel.dart';
import '../models/clients/receiptAddModel.dart';
import '../models/clients/receiptByInvModel.dart';
import '../models/clients/receiptFileDeleteModel.dart';
import '../models/clients/receiptListModel.dart';
import '../models/clients/viewReceiptPdfModel.dart';
import '../models/complaints/add_item_model.dart';
import '../models/complaints/delete_model.dart';
import '../models/complaints/details_model.dart';
import '../models/complaints/get_model.dart';
import '../models/complaints/list_model.dart';
import '../models/complaints/post_model.dart';
import '../models/complaints/post_remark_model.dart';
import '../models/complaints/update_model.dart';
import '../models/fileManager/deleteFileModel.dart';
import '../models/fileManager/fileMagerMOdel.dart';
import '../models/fileManager/mainFileManagerPermissionModel.dart';
import '../models/fileManager/renameFileModel.dart';
import '../models/lead_management/BulkTransferLeadModel.dart';
import '../models/lead_management/TransferLeadModel.dart';
import '../models/lead_management/addBulkContactGroupModel.dart';
import '../models/lead_management/addLeadFollowupModel.dart';
import '../models/lead_management/addLeadSubCategoryModel.dart';
import '../models/lead_management/bulkDeleteLeadModel.dart';
import '../models/lead_management/callResultResonModel.dart';
import '../models/lead_management/checkLeadPhoneNumberModel.dart';
import '../models/lead_management/createFolderModel.dart';
import '../models/lead_management/deleteFolderAndFileModel.dart';
import '../models/lead_management/deleteLeadMileStoneModel.dart';
import '../models/lead_management/deleteLeadVoiceModel.dart';
import '../models/lead_management/delete_notification.dart';
import '../models/lead_management/editLeadSubCategoryModel.dart';
import '../models/lead_management/leadCategoryStaffWiseModel.dart';
import '../models/lead_management/leadDeatailsModelAdd.dart';
import '../models/lead_management/leadMileStoneListModel.dart';
import '../models/lead_management/leadNotificationListModel.dart';
import '../models/lead_management/leadSubCategoryDeleteModel.dart';
import '../models/lead_management/leadSubTypeModel.dart';
import '../models/lead_management/listFolderName.dart';
import '../models/lead_management/readLeadNotificationModel.dart';
import '../models/lead_management/renameFolderModel.dart';
import '../models/lead_management/testListApiModel.dart';
import '../models/lead_management/unsetReminderModel.dart';
import '../models/lead_management/updateReminderSetings.dart';
import '../models/lead_management/uploadAudioRecoed.dart';
import '../models/lead_management/viewLeadSubCategoryModel.dart';
import '../models/officialWhatsapp/chat_list_model.dart';
import '../models/officialWhatsapp/addContactModel.dart';
import '../models/officialWhatsapp/campaignsListModel.dart';
import '../models/officialWhatsapp/mediaModel.dart';
import '../models/officialWhatsapp/official_message_model.dart';
import '../models/officialWhatsapp/officialWhatsappConfigureModel.dart';
import '../models/officialWhatsapp/sendMesaageModel.dart';
import '../models/officialWhatsapp/sendTemplateMesaageModel.dart';
import '../models/officialWhatsapp/template_content_model.dart';
import '../models/officialWhatsapp/templateModel.dart';
import '../models/removeUserModel.dart';
import '../models/resetPasswordModel.dart';
import '../models/settings/deleteFbLeadsModel.dart';
import '../models/settings/facebookSettingsModel.dart';
import '../models/settings/sendNotificationModel.dart';
import '../models/settings/updateFbLeadAssignStaff.dart';
import '../models/userManagement/deleteDesignationModel.dart';
import '../models/userManagement/postEditStaffPermissionModel.dart';
import '../models/userManagement/postEditStaffSubmenuModel.dart';
import '../models/userManagement/staffDetailsModel.dart';
import '../models/userPermissionModel.dart';
import '../models/verifyPhoneModel.dart';

class HttpService {
  static final Dio _dio = Dio();

  // static String get baseUrl => Platform.isIOS
  //     ? "https://account.login2.in/index.php/Mobile_app_api_ios_v1/"
  //     : "https://account.login2.in/index.php/Mobile_app_api_v1/";

  // static String get baseUrl => Platform.isIOS
  //     ? "https://account.login2.in/index.php/Mobile_app_api_ios_v3/"
  //     : "${await Config.getUrl()}";

  static Future configure(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}check_package_expired",
          // options: Options(receiveTimeout: const Duration(microseconds: 30)),
          queryParameters: params);
      if (kDebugMode) {}
      CommonConfigureModel model = CommonConfigureModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future backgroundData(body) async {
    try {
      var result = await _dio.get("${await Config.getUrl()}getClientName",
          queryParameters: body);
      if (kDebugMode) {}
      BackgroundModel model = BackgroundModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future forceUpdate() async {
    try {
      var result = await _dio.get(
        "https://account.login2.in/serverAuth.php",
        // options: Options(receiveTimeout: const Duration(seconds: 30)),
      );
      if (kDebugMode) {}
      UpdateModel model = UpdateModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future commonSettings() async {
    try {
      var result = await _dio.get(
        "${await Config.getUrl()}contact_us",
      );
      CommonSettingsModel model = CommonSettingsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future login(
      String username, String pass, String firebaseToken) async {
    var params = {
      "phoneNumber": username,
      "password": pass,
      "firebaseId": firebaseToken
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}login",
          queryParameters: params);

      if (result.statusCode == 200) {
        LoginModel model = LoginModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future loginCheck(token, firebaseToken) async {
    var params = {"token": token, "firebaseId": firebaseToken};
    try {
      var result = await _dio.get("${await Config.getUrl()}if_token_expired",
          queryParameters: params);
      LoginCheckModel model = LoginCheckModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future sendOtp(phoneNumber, otp) async {
    var params = {
      "phoneNumber": phoneNumber,
      "otp": otp,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}send_otp",
          queryParameters: params);
      SendOtpModel model = SendOtpModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* Lead Management  Starts Here..*/
  static Future leadDashboard(
      token, fromDate, toDate, fromDate1, toDate1) async {
    log(token);
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_dashboard",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      LeadDashboardModel model = LeadDashboardModel.fromJson(result.data);
      return model;
    } catch (e) {
      log(e.toString());
    }
  }

  static Future leadDashboard1(
      token, fromDate, toDate, fromDate1, toDate1) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}lead_category_staff_wise",
          queryParameters: params);
      LeadCategoryStaffWiseModel model =
          LeadCategoryStaffWiseModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDashboardStaff(
      token, fromDate, toDate, fromDate1, toDate1, staffId) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
      "staffId": staffId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}staff_dashboard",
          queryParameters: params);
      StaffDashboardModel model = StaffDashboardModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDashboard1Staff(
      token, fromDate, toDate, fromDate1, toDate1, staffId) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "fromDate1": fromDate1,
      "toDate1": toDate1,
      "staffId": staffId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}staff_lead_category_wise",
          queryParameters: params);
      LeadCategoryStaffWiseModel model =
          LeadCategoryStaffWiseModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future allViewLeads(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}view_total_lead_report",
          data: jsonEncode(body));
      ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future transferLeadReport(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}view_transfer_lead_history",
          data: jsonEncode(body));
      TransferLeadModel model = TransferLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeads(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}view_lead_report",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          data: jsonEncode(body));
      if (result.statusCode == 200) {
        ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsSts(token, fromdate, todate, type, id, status, sort,
      page, pageSize, isFirst, branchId) async {
    var params = {
      "token": token,
      "fromDate": fromdate,
      "toDate": todate,
      "type": type,
      "id": id,
      "status": status,
      "sort": sort,
      "page": page,
      "pageSize": pageSize,
      "isFirst": isFirst,
      "branchId": branchId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}view_category_staff_wise_lead_report",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      ViewLeadsModel model = ViewLeadsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadCommonData(token, {branchId}) async {
    var params = {"token": token, "branchId": branchId};

    try {
      var result = await _dio.get(
          "${await Config.getUrl()}lead_management_master_data",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);

      if (result.statusCode == 200) {
        AddLeadCommonDataModel model =
            AddLeadCommonDataModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeads(
    token,
    branchId,
    clientName,
    leadType,
    leadSubType,
    contactNo,
    staffId,
    cost,
    priorityId,
    address,
    remark,
    callResultId,
    nextFollowupDate,
    descriptions,
    code,
    checked,
    timeBefore,
    // leadSource
  ) async {
    var formData = FormData.fromMap({
      'token': token,
      'branchId': branchId,
      'next_followup_date': nextFollowupDate,
      'call_result_id': callResultId,
      'lead_category_id': leadType,
      'lead_sub_category_id': leadSubType,
      'clientName': clientName,
      'contactNumber': contactNo,
      'address': address,
      'cost': cost,
      'user_id': staffId,
      'remarks': remark,
      'priority': priorityId,
      'country_code': code,
      "additionalFields": jsonEncode(descriptions),
      "reminder": checked,
      "time_before": timeBefore,
      // "lead_source":leadSource
    });

    try {
      var result =
          await _dio.post("${await Config.getUrl()}add_leads", data: formData);
      AddLeadModel model = AddLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsCategory(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_category",
          queryParameters: params);
      ViewLeadCategoryModel model = ViewLeadCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadCategory(token, categoryName) async {
    var params = {
      "token": token,
      "leadCategory": categoryName,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}add_lead_category",
          queryParameters: params);
      AddLeadCategoryModel model = AddLeadCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadCategory(token, categoryName, categoryId) async {
    var params = {
      "token": token,
      "leadCategory": categoryName,
      'leadCategoryId': categoryId
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}edit_lead_category",
          queryParameters: params);
      EditLeadCategoryModel model = EditLeadCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadCategory(token, categoryId) async {
    var params = {
      "token": token,
      "leadCategoryId": categoryId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}delete_lead_category",
          queryParameters: params);
      LeadCategoryDeleteModel model =
          LeadCategoryDeleteModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewLeadsSubCategory(token, categoryId) async {
    var params = {"token": token, "leadCategoryId": categoryId};
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_sub_category",
          queryParameters: params);
      ViewLeadSubCategoryModel model =
          ViewLeadSubCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadSubCategory(token, categoryName, categoryId) async {
    var params = {
      "token": token,
      "leadSubCategory": categoryName,
      "leadCategoryId": categoryId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}add_lead_sub_category",
          queryParameters: params);
      AddLeadSubCategoryModel model =
          AddLeadSubCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadSubCategory(
      token, subCategoryName, subCategoryId) async {
    var params = {
      "token": token,
      "leadSubCategory": subCategoryName,
      'leadSubCategoryId': subCategoryId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}edit_lead_sub_category",
          queryParameters: params);
      EditLeadSubCategoryModel model =
          EditLeadSubCategoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadSubCategory(token, subCategoryId) async {
    var params = {
      "token": token,
      "leadSubCategoryId": subCategoryId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}delete_lead_sub_category",
          queryParameters: params);
      LeadSubCategoryDeleteModel model =
          LeadSubCategoryDeleteModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadSubType(categoryId) async {
    var params = {
      "leadCategoryId": categoryId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}get_sub_categories",
          queryParameters: params);
      LeadSubTypeModel model = LeadSubTypeModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadDetails(token, callMasterId) async {
    var params = {
      "token": token,
      "call_master_id": callMasterId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}lead_details",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);

      if (result.statusCode == 200) {
        LeadDeatailsModel model = LeadDeatailsModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addLeadsFollowup(
      token,
      callResultId,
      nextFollowupDate,
      cost,
      address,
      leadTypeId,
      leadSubType,
      remarks,
      callMasterId,
      calledDate,
      callHistoryId,
      priorityId,
      checked,
      timeBefore,
      callResponseId,
      reasonId,
      createSales,
      createType,
      checkIdVal,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff,
      isDiff,
      renProducts) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResultId,
      "lead_category_id": leadTypeId,
      "lead_sub_category_id": leadSubType,
      "cost": cost,
      "remarks": remarks,
      "call_master_id": callMasterId,
      "called_date": calledDate,
      "cloud_call_id": callHistoryId,
      "address": address,
      "priority": priorityId,
      "reminder": checked,
      "time_before": timeBefore,
      "call_response_id": callResponseId,
      "reason_id": reasonId,
      "create_sales": createSales,
      "create_type": createType,
      "check_id_val": checkIdVal,
      "invoice_date": invoiceDate,
      "product_list": jsonEncode(productList),
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
      "next_cost_diff": isDiff,
      "next_renewal_product": jsonEncode(renProducts),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}add_lead_followup",
          data: formData);
      AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postConfirmedFollowup(
      callMasterId,
      invoiceRemarks,
      renewalRemarks,
      createType,
      checkIdVal,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff,
      isDiff,
      renProducts) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "invoice_remarks": invoiceRemarks,
      "renewal_remarks": renewalRemarks,
      "call_master_id": callMasterId,
      "create_type": createType,
      "check_id_val": checkIdVal,
      "invoice_date": invoiceDate,
      "product_list": jsonEncode(productList),
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
      "next_cost_diff": isDiff,
      "next_renewal_product": jsonEncode(renProducts),
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postConfirmedFollowup",
          data: formData);
      if (result.statusCode == 200) {
        AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeadsFollowup(
      token,
      callFollowupId,
      callResultId,
      nextFollowupDate,
      cost,
      leadTypeId,
      leadSubTypeId,
      remarks,
      calledDate,
      callMasterId,
      callResponseId,
      reasonId) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResultId,
      "lead_category_id": leadTypeId,
      "lead_sub_category_id": leadSubTypeId,
      "cost": cost,
      "remarks": remarks,
      "call_details_id": callFollowupId,
      "called_date": calledDate,
      'call_master_id': callMasterId,
      'call_response_id': callResponseId,
      'reason_id': reasonId,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}edit_lead_followup",
          data: formData);
      EditLeadFollowupModel model = EditLeadFollowupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadFollowup(token, followupId, callMasterId) async {
    var formData = FormData.fromMap({
      "token": token,
      'call_master_id': callMasterId,
      "call_details_id": followupId,
    });

    try {
      var result = await _dio
          .post("${await Config.getUrl()}delete_lead_followup", data: formData);
      DeleteLeadFollowModel model = DeleteLeadFollowModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editLeads(
    token,
    callMasterId,
    branchId,
    clientName,
    leadType,
    leadSubTypeId,
    contactNo,
    staffId,
    cost,
    priorityId,
    address,
    remark,
    descriptions,
    code,
    // leadSource
  ) async {
    var formData = FormData.fromMap({
      'token': token,
      'branchId': branchId,
      'lead_category_id': leadType,
      'lead_sub_category_id': leadSubTypeId,
      'clientName': clientName,
      'contactNumber': contactNo,
      'address': address,
      'cost': cost,
      'user_id': staffId,
      'remarks': remark,
      'priority': priorityId,
      'call_master_id': callMasterId,
      'country_code': code,
      "additionalFields": jsonEncode(descriptions),
      // "lead_source":leadSource
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}edit_lead_data",
          data: formData);

      EditLeadModel model = EditLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadTransfer(token, callMasterId, staff, remark) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
      "staff_id": staff,
      "remarks": remark,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}transfer_leads",
          data: formData);
      LeadTransferModel model = LeadTransferModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future followupDetails(token, callDetailsId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_details_id": callDetailsId,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}get_lead_followup_details",
          data: formData);
      FollowupDetailsModel model = FollowupDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadProgressbar(token, fromDate, toDate, callStatus) async {
    var formData = FormData.fromMap({
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "callStatus": callStatus,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}lead_progressbar_data",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadProgressbarStaff(
      token, fromDate, toDate, callStatus, staffId) async {
    var formData = FormData.fromMap({
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "callStatus": callStatus,
      "staffId": staffId,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}staff_lead_progressbar_data",
          data: formData);
      LeadProgressbarModel model = LeadProgressbarModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLead(token, callMasterId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}delete_lead_master",
          data: formData);
      DeleteLeadModel model = DeleteLeadModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future bulkDeleteLead(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}lead_bulk_delete",
          data: jsonEncode(body));
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      BulkDeleteLeadModel model = BulkDeleteLeadModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future bulkTransferLead(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}bulk_transfer_leads",
          data: jsonEncode(body));
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      BulkTransferLeadModel model = BulkTransferLeadModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addBulkContactGroup(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}lead_bulk_message",
          data: jsonEncode(body));
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      AddBulkContactGroupModel model =
          AddBulkContactGroupModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addCloudCall(token, callMasterId, phoneNumber) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMasterId,
      "phoneNumber": phoneNumber,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}add_cloud_call",
          data: formData);
      // print(result);
      CloudCallModel model = CloudCallModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callHistory(token, userId, fromDate, toDate) async {
    //print(userId);
    var formData = FormData.fromMap({
      "token": token,
      "staff_id": userId,
      "fromDate": fromDate,
      "toDate": toDate,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}call_history",
          data: formData);
      //print(result);
      CallHistoryModel model = CallHistoryModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future searchLead(token, search) async {
    var params = {
      "token": token,
      "searchKey": search,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}search_lead_clients",
          queryParameters: params);
      //  print(params);
      //print(result);

      SearchModel model = SearchModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* Lead Management  Ends Here..*/
/* User Management Starts Here..*/
  static Future menuList(token) async {
    var params = {
      "token": token,
    };
    //print(params);
    try {
      var result = await _dio.get("${await Config.getUrl()}get_package_menus",
          queryParameters: params);

      MenuModel model = MenuModel.fromJson(result.data);
      // print(result);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editMenuList(token, designationId) async {
    var formData = FormData.fromMap({
      "token": token,
      "designation_id": designationId,
    });

    try {
      var result = await _dio
          .post("${await Config.getUrl()}designation_details", data: formData);
      //print(result);
      EditDesignationDetailsModel model =
          EditDesignationDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postSubMenu(body) async {
    //print(body);
    try {
      var result = await _dio.post("${await Config.getUrl()}post_designation",
          data: jsonEncode(body));
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      PostSubmenuModel model = PostSubmenuModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postEditSubMenu(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}edit_designation",
          data: jsonEncode(body));

      PostEditSubmenuModel model = PostEditSubmenuModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postEditStaffSubMenu(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}edit_staff_modules",
          data: jsonEncode(body));

      PostEditStaffSubmenuModel model =
          PostEditStaffSubmenuModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postEditStaffPermission(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}edit_staff_permissions",
          data: jsonEncode(body));

      PostEditStaffPermissionModel model =
          PostEditStaffPermissionModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future designationList(token) async {
    var params = {
      "token": token,
    };

    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_designation_list",
          queryParameters: params);

      DesignationListModel model = DesignationListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewStaffs(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });

    try {
      var result =
          await _dio.post("${await Config.getUrl()}staff_list", data: formData);
      ViewStaffModel model = ViewStaffModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addUserCommonData(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}userDetailsData",
          data: formData);
      AddUserCommonDataModel model =
          AddUserCommonDataModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postUserData(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}add_staff",
          data: jsonEncode(body));
      AddUserModel model = AddUserModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editUserBasicData(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}update_staff",
          data: jsonEncode(body));
      EditUserBasicDetailsModel model =
          EditUserBasicDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future uploadImages(formData) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}add_staff_image",
          data: formData);

      AddUserImageModel model = AddUserImageModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateUploadImages(formData) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}update_staff_image",
          data: formData);

      AddUserImageModel model = AddUserImageModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteStaff(token, staffId) async {
    var formData = FormData.fromMap({
      "token": token,
      "staffUserId": staffId,
    });

    try {
      var result = await _dio.post("${await Config.getUrl()}delete_staff",
          data: formData);

      DeleteStaffModel model = DeleteStaffModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future changePassword(token, confirmPassword, staffUserId) async {
    var formData = FormData.fromMap({
      "token": token,
      "staffUserId": staffUserId,
      "password": confirmPassword,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}change_staff_password",
          data: formData);
      ChangePasswordModel model = ChangePasswordModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future staffDetails(token, staffId) async {
    var params = {"token": token, "staff_id": staffId};
    try {
      var result = await _dio.get("${await Config.getUrl()}staff_details",
          queryParameters: params);
      if (kDebugMode) {
        print(result);
      }
      StaffDetailsModel model = StaffDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* User Management Ends Here..*/
/* Settings Starts Hers */
  static Future whatsappSettings(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_whatsapp_settings",
          queryParameters: params);

      WhatsappSettingsModel model = WhatsappSettingsModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addWhatsappSettings(
      accessToken, instanceId, token, phoneNumber) async {
    var params = {
      "accessToken": accessToken,
      "instanceId": instanceId,
      "token": token,
      "phoneNumber": phoneNumber
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_unofficial_whatsapp",
          queryParameters: params);

      AddWhatsappSettingsModel model =
          AddWhatsappSettingsModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addWhatsappSettingsOffical(
      phoneNumberId, accountId, token, permanentToken) async {
    var params = {
      "accountId": accountId,
      "permanentToken": permanentToken,
      "token": token,
      "phoneNumberId": phoneNumberId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_official_whatsapp",
          queryParameters: params);

      AddWhatsappSettingsOffModel model =
          AddWhatsappSettingsOffModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* Settings Ends Here */

/* Main User Starts Here.. */
  static Future mainDashboard(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });
    try {
      log("${await Config.getUrl()}get_active_package");
      var result = await _dio.post("${await Config.getUrl()}get_active_package",
          data: formData);
      DashboardModel model = DashboardModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future changeUserPassword(token, password) async {
    var formData = FormData.fromMap({
      "token": token,
      "password": password,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}reset_password",
          data: formData);
      UserChangePasswordModel model =
          UserChangePasswordModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* Main Users Ends Here..*/
/* Contact Group Starts Here..*/
  static Future contactGroup(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_contact_group",
          data: formData);

      ContactGroupModel model = ContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future contactGroupDetails(token, id) async {
    var formData = FormData.fromMap({
      "token": token,
      "group_id": id,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_group_messages",
          data: formData);
      ContactGroupDeatailsModel model =
          ContactGroupDeatailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future sendWhatsappBulkMessage(formData) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}send_bulk_message",
          data: formData);

      SendMessageModel model = SendMessageModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addContactGroup(token, groupName, numbers) async {
    var formData = FormData.fromMap({
      "token": token,
      "group_name": groupName,
      "contact_numbers": numbers,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_new_contact_group",
          data: formData);

      AddContactGroupModel model = AddContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future groupInfo(token, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "group_id": groupId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}get_group_details",
          data: formData);
      GroupInfoModel model = GroupInfoModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editContactGroupName(token, groupName, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contact_group_name": groupName,
      "contact_group_id": groupId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}update_group_name",
          data: formData);
      EditContactGroupModel model = EditContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteContactGroup(token, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contact_group_id": groupId,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}delete_contact_group", data: formData);
      DeleteContactGroupModel model =
          DeleteContactGroupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addContactNumber(token, numbers, groupId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contact_group_id": groupId,
      "contact_numbers": numbers,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}add_contact_numbers", data: formData);
      AddContactNumberModel model = AddContactNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editContactNumber(token, number, contactNumberId) async {
    var formData = FormData.fromMap({
      "token": token,
      "contct_number_id": contactNumberId,
      "contact_number": number,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}edit_contact_number", data: formData);
      EditContactNumberModel model =
          EditContactNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteContactNumber(token, id) async {
    var formData = FormData.fromMap({
      "token": token,
      "contct_number_id": id,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}delete_contact_number",
          data: formData);

      DeleteContactNumberModel model =
          DeleteContactNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

/* Contact Group Ends Here...*/

  static Future verifyPhone(phoneNumber) async {
    var params = {
      "phoneNumber": phoneNumber,
    };
    try {
      log("${await Config.getUrl()}verify_phone");
      var result = await _dio.get("${await Config.getUrl()}verify_phone",
          queryParameters: params);
      if (result.statusCode == 200) {
        VerifyPhoneModel model = VerifyPhoneModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
      Common.toastMessaage("Something went wrong", Colors.red);
    }
  }

  static Future resetPassword(phoneNumber, password) async {
    var params = {
      "phoneNumber": phoneNumber,
      "password": password,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}forgot_password",
          queryParameters: params);
      ResetPasswordModel model = ResetPasswordModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future removeUser(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_user",
          queryParameters: params);
      RemoveUserModel model = RemoveUserModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future createFolder(token, callMaterId, path) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}createFolder",
          data: formData);
      CreateFolderModel model = CreateFolderModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future uploadRecord(
      token, callMaterId, path, uploadFile, fileName) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
      "file_name": fileName,
      "uploadFile": await MultipartFile.fromFile(uploadFile),
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}uploadFile", data: formData);
      UploadAudioRecord model = UploadAudioRecord.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future listFolderAndFiles(token, callMaterId, path) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}getUploads", data: formData);
      if (result.statusCode == 200) {
        ListFolderNameModel model = ListFolderNameModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadFolderAndFiles(
      token, callMasterId, path, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      'call_master_id': callMasterId,
      "path": path,
      "row_id": rawId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteUploads",
          data: formData);
      DeleteFolderAndFileModel model =
          DeleteFolderAndFileModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future renameFolder(
      token, callMaterId, path, prevName, newName, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": callMaterId,
      "path": path,
      "prev_name": prevName,
      "new_name": newName,
      "row_id": rawId
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}renameUploadedFile",
          data: formData);
      RenameFolderModel model = RenameFolderModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fetchData(page, pageSize) async {
    var params = {"page": page, "pageSize": pageSize};

    try {
      var result = await _dio.get("${await Config.getUrl()}view_leads_test",
          queryParameters: params);
      TestListApiModel model = TestListApiModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future listAddonDet(token, callMaterId) async {
    var params = {"token": token, "call_master_id": callMaterId};

    try {
      var result = await _dio.get("${await Config.getUrl()}lead_details_data",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      if (result.statusCode == 200) {
        LeadDeatailsModelAdd model = LeadDeatailsModelAdd.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fileManagerPermission(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}file_manager_data",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      FileManagerPermissionModel model =
          FileManagerPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateReminder(token, detailsId, checked, time) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_details_id": detailsId,
      "reminder": checked,
      "time_before": time,
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}update_followup_reminder",
          data: formData);
      UpdateReminderSetting model = UpdateReminderSetting.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteDesignation(token, designationId) async {
    var params = {
      "token": token,
      "designation_id": designationId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_designation",
          queryParameters: params);
      DeleteDesignationModel model =
          DeleteDesignationModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fileManagerPermissionMain(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}file_manager_permission",
          queryParameters: params);
      MainFileManagerPermissionModel model =
          MainFileManagerPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainListFolderAndFiles(token, path) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": path,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getUploadsData",
          data: formData);
      FileManagerModel model = FileManagerModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fileUpload(token, folderName, uploadFile, fileName) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": folderName,
      "file_name": fileName,
      "uploadFile": await MultipartFile.fromFile(uploadFile),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}uploadNewFile",
          data: formData);
      UploadAudioRecord model = UploadAudioRecord.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future renameFile(token, folderName, prevName, newName, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": folderName,
      "prev_name": prevName,
      "new_name": newName,
      "row_id": rawId
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}renameFile", data: formData);
      RenameFileModel model = RenameFileModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteFiles(token, folderName, fileName, rawId) async {
    var formData = FormData.fromMap({
      "token": token,
      "folderName": folderName,
      "fileName": fileName,
      "row_id": rawId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteUploadFile",
          data: formData);
      DeleteFileModel model = DeleteFileModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future unsetReminder(token, callDetailsId) async {
    var params = {
      "token": token,
      "call_details_id": callDetailsId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}unset_reminder",
          queryParameters: params);
      UnsetReminderModel model = UnsetReminderModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fbDetails(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}fbSettingDetails",
          queryParameters: params);
      FacebookSettingsModel model = FacebookSettingsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateAssignStaffFbLead(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}update_fb_lead_assigned_staff",
          data: jsonEncode(body));
      UpdateFbLeadAssignStaff model =
          UpdateFbLeadAssignStaff.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteFbLeads(token, fbLeadId) async {
    var params = {
      "token": token,
      "fb_settings_id": fbLeadId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_fb_settings",
          queryParameters: params);
      DeleteFbLeadsModel model = DeleteFbLeadsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future sendLeadNotification(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}update_push_notification_staff",
          data: jsonEncode(body));
      SendNotificationModel model = SendNotificationModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogUpload(body) async {
    try {
      var result = await _dio.post("${await Config.getUrl()}add_phone_call_log",
          data: jsonEncode(body));
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      if (result.statusCode == 200) {
        CallLogUploadModel model = CallLogUploadModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogHistory(token, fromDate, toDate, staffId) async {
    var params = {
      "token": token,
      "fromDate": fromDate,
      "toDate": toDate,
      "staffId": staffId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}get_phone_call_log",
          queryParameters: params);
      CallLogHistoryModel model = CallLogHistoryModel.fromJson(result.data);
      if (result.statusCode == 200) {
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteCallHistoryLogs(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}delete_phone_call_log",
          data: jsonEncode(body));
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      DeleteCallHistoryModel model =
          DeleteCallHistoryModel.fromJson(result.data);

      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainClients(
      token, searchKey, fromDate, toDate, page, pageSize) async {
    var params = {
      "token": token,
      "search_key": searchKey,
      "from_date": fromDate == "From Date" ? "" : fromDate,
      "to_date": toDate == "To Date" ? "" : toDate,
      "page": page,
      "page_size": pageSize
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}mainClientList",
          queryParameters: params);
      if (result.statusCode == 200) {
        MainClientListModel model = MainClientListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future mainClientDetails(token, clientId) async {
    var params = {"token": token, "clientId": clientId};
    try {
      var result = await _dio.get("${await Config.getUrl()}mainClientDetails",
          queryParameters: params);
      MainClientDetailsModel model =
          MainClientDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteMainClients(token, clientId) async {
    var params = {"token": token, "client_id": clientId};
    try {
      var result = await _dio.get("${await Config.getUrl()}deleteMainClients",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteMainClientModel model =
            DeleteMainClientModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadConvertToClient(token, leadId, addCustomField) async {
    var params = {
      "token": token,
      "lead_id": leadId,
      "add_custom_fields": addCustomField
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}convert_lead",
          queryParameters: params);
      LeadConvertToClientModel model =
          LeadConvertToClientModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addClients(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}postClient", data: body);
      AddClientsModel model = AddClientsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceCommonDetails(token, clientId) async {
    var params = {
      "token": token,
      "client_id": clientId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getInvoiceDetails",
          queryParameters: params);
      InvoiceAddCommonDetailsModel model =
          InvoiceAddCommonDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addInvoice(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}postInvoice", data: body);
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      if (result.statusCode == 200) {
        AddInvoiceModel model = AddInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editInvoice(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}updateInvoice", data: body);
      if (kDebugMode) {
        print(body);
      }
      if (kDebugMode) {
        print(result);
      }
      EditInvoiceModel model = EditInvoiceModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceList(
      token, fromDate, toDate, clientId, staff, type) async {
    var formData = FormData.fromMap({
      'token': token,
      'from_date': fromDate,
      'to_date': toDate,
      'client_id': clientId,
      'collected_by': staff,
      'invoice_type': type
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceLists",
          data: formData);
      InvoiceListModel model = InvoiceListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future pendingInvoiceList(token) async {
    var formData = FormData.fromMap({
      'token': token,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getPendingInvoiceLists",
          data: formData);
      PendingInvoiceListModel model =
          PendingInvoiceListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteInvoice(token, invoiceId) async {
    var params = {"token": token, "invoice_id": invoiceId};
    try {
      var result = await _dio.get("${await Config.getUrl()}deleteInvoice",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteInvoiceModel model = DeleteInvoiceModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future customerList(
    token,
  ) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getCustomerLists",
          queryParameters: params);
      CustomerListModel model = CustomerListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getInvoiceSearch(
    token,
  ) async {
    var formData = FormData.fromMap({"token": token});

    try {
      var result = await _dio
          .post("${await Config.getUrl()}getInvoiceSearchData", data: formData);
      GetInvoiceSearchData model = GetInvoiceSearchData.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future receptList(
      token, fromDate, toDate, page, pageSize, searchKey) async {
    var formData = FormData.fromMap({
      'token': token,
      'from_date': fromDate == "From Date" ? "" : fromDate,
      'to_date': toDate == "To Date" ? "" : toDate,
      'page': page,
      'page_size': pageSize,
      'search_key': searchKey,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getReceiptLists",
          data: formData);
      if (result.statusCode == 200) {
        ReceiptListModel model = ReceiptListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceReceptList(token, invoiceId) async {
    var formData = FormData.fromMap({'token': token, 'invoice_id': invoiceId});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getInvoiceReceiptLists",
          data: formData);
      ReceiptByInvModel model = ReceiptByInvModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteReceipt(token, receiptId) async {
    var formData = FormData.fromMap({
      'token': token,
      'receipt_id': receiptId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteReceipt",
          data: formData);
      if (result.statusCode == 200) {
        ReceiptDeleteModel model = ReceiptDeleteModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future receiptCommonDetails(token, clientId, invoiceId) async {
    var params = {
      "token": token,
      "client_id": clientId,
      "invoice_id": invoiceId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getReceiptDetails",
          queryParameters: params);
      ReceiptAddCommonDetailsModel model =
          ReceiptAddCommonDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editClientDetails(token, clientId) async {
    var params = {"token": token, "clientId": clientId};

    try {
      var result = await _dio.get("${await Config.getUrl()}getClientById",
          queryParameters: params);
      EditClientDetailsModel model =
          EditClientDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editClients(body) async {
    try {
      var result =
          await _dio.post("${await Config.getUrl()}updateClient", data: body);
      EditClientsModel model = EditClientsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future fetchPostOffice(postalCode) async {
    try {
      var result =
          // ignore: prefer_interpolation_to_compose_strings
          await _dio.get("https://api.postalpincode.in/pincode/" + postalCode);
      PostalCodeModel model = PostalCodeModel.fromJson(result.data[0]);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addReceipt(
      token,
      invoiceId,
      clientId,
      receiptNumber,
      receiptDate,
      paidAmount,
      collectedBy,
      paymentMethod,
      templateImage) async {
    var formData = FormData.fromMap({
      'token': token,
      'invoice_id': invoiceId,
      'client_id': clientId,
      'receipt_number': receiptNumber,
      'receipt_date': receiptDate,
      'paid_amount': paidAmount,
      'collected_staff': collectedBy,
      'payment_method': paymentMethod,
      'upload_file': templateImage != null
          ? await MultipartFile.fromFile(templateImage.toString())
          : ''
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postReceipt",
          data: formData);
      if (result.statusCode == 200) {
        ReceiptAddModel model = ReceiptAddModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editReceiptDetails(token, receiptId) async {
    var params = {
      "token": token,
      "receipt_id": receiptId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getReceiptById",
          queryParameters: params);
      EditReceiptModelDetailsModel model =
          EditReceiptModelDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future editReceipt(token, receiptId, receiptDate, paidAmount,
      collectedBy, paymentMethod, templateImage) async {
    var formData = FormData.fromMap({
      'token': token,
      'receipt_id': receiptId,
      'receipt_date': DateFormat("dd-MM-yyyy")
          .format(DateTime.parse(receiptDate.toString())),
      'paid_amount': paidAmount,
      'collected_staff': collectedBy,
      'payment_method': paymentMethod,
      'upload_file': templateImage != null
          ? await MultipartFile.fromFile(templateImage.toString())
          : ''
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}updateReceipt",
          data: formData);
      EditReceiptModel model = EditReceiptModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadMileStone(token, subCategoryId) async {
    var params = {
      "token": token,
      "leadMasterId": subCategoryId,
    };

    try {
      var result = await _dio.get("${await Config.getUrl()}get_milestones",
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          queryParameters: params);
      LeadMileStoneListModel model =
          LeadMileStoneListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addMileStone(body) async {
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_lead_milestones",
          data: jsonEncode(body));
      AddMileStoneModel model = AddMileStoneModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadNotificationList(token) async {
    var params = {
      "token": token,
    };

    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_all_lead_milestones",
          queryParameters: params);
      LeadNotificationListModel model =
          LeadNotificationListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteNotification(token, String notificaionId) async {
    var params = {
      "token": token,
      "notification_id": notificaionId,
    };

    try {
      var result = await _dio.get("${await Config.getUrl()}delete_notification",
          queryParameters: params);
      if (result.statusCode == 200) {
        DeleteNotification model = DeleteNotification.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future readLeadNotification(token, notificationId) async {
    var params = {
      "token": token,
      "notification_id": notificationId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_notification_read_status",
          queryParameters: params);
      ReadLeadNotificationModel model =
          ReadLeadNotificationModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteMileStoneLeads(token, leadMileStoneId) async {
    var params = {
      "token": token,
      "lead_milestone_id": leadMileStoneId,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}delete_lead_milestones",
          queryParameters: params);
      DeleteLeadMileStoneModel model =
          DeleteLeadMileStoneModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future checkLeadPhoneNumber(token, contactNumber, code) async {
    var params = {
      "token": token,
      "contactNumber": code + contactNumber,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}check_lead_contact_exist",
          queryParameters: params);
      CheckLeadPhoneNumberModel model =
          CheckLeadPhoneNumberModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getBranchList(token) async {
    var formData = FormData.fromMap({
      "token": token,
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}getBranch", data: formData);
      // ${await Config.getUrl()}getBranch
      BranchListModel model = BranchListModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future invoiceEditDetails(token, invId) async {
    var formData = FormData.fromMap({
      "token": token,
      "invoice_id": invId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getInvoiceById",
          data: formData);
      EditInvoiceDetailsModel model =
          EditInvoiceDetailsModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future leadVoiceUpload(
      token, leadMasterId, leadDetailsId, uploadFile) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": leadMasterId,
      "call_details_id": leadDetailsId,
      "uploadFile": await MultipartFile.fromFile(uploadFile),
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}add_follow_up_voice_note",
          data: formData);
      if (result.statusCode == 200) {
        UploadAudioRecord model = UploadAudioRecord.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteLeadVoice(token, leadMasterId, leadDetailsId) async {
    var formData = FormData.fromMap({
      "token": token,
      "call_master_id": leadMasterId,
      "call_details_id": leadDetailsId,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteVoiceNote",
          data: formData);
      DeleteLeadVoiceModel model = DeleteLeadVoiceModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callResultReasonLiat(token, callResultId) async {
    var params = {"token": token, "callResultId": callResultId};
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}get_lead_result_reasons",
          queryParameters: params);
      CallResultResonModel model = CallResultResonModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future userPermissionCheck(token) async {
    var params = {
      "token": token,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}user_permissions",
          queryParameters: params);
      UserPermissionModel model = UserPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteReceiptFile(token, receiptId) async {
    var formData = FormData.fromMap({
      'token': token,
      'receipt_id': receiptId,
    });
    try {
      var result =
          await _dio.post("${await Config.getUrl()}deleteFile", data: formData);
      ReceiptFileDeleteModel model =
          ReceiptFileDeleteModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewReceiptPdf(token, receiptId) async {
    var params = {
      "token": token,
      "receipt_id": receiptId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}viewReceiptById",
          queryParameters: params);
      ViewReceiptPdfModel model = ViewReceiptPdfModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static fetchChatList(searchKey, page, pageSize) async {
    try {
      var response = await _dio
          .get("${await Config.getUrl()}official_whatsapp", queryParameters: {
        "searchKey": searchKey,
        "token": await Common.getSharedPref("token"),
        "pageNo": page,
        "pageSize": pageSize,
      });
      if (response.statusCode == 200) {
        ChatListModel chatListModel = ChatListModel.fromJson(response.data);
        return chatListModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      // print("Exception: $e");
    }
  }

  static fetchCampaignsList(searchKey) async {
    try {
      var response = await _dio
          .get("${await Config.getUrl()}get_campaigns", queryParameters: {
        "token": await Common.getSharedPref("token"),
      });

      CampaignsListModel campaignsListModel =
          CampaignsListModel.fromJson(response.data);

      return campaignsListModel;
    } catch (e) {
      // print("Exception: $e");
    }
  }

  static addContact(
    contactName,
    contryCode,
    contaCtNumber,
  ) async {
    var formData = FormData.fromMap({
      "contact_name": contactName,
      'country_code': contryCode,
      'contact_number': contaCtNumber,
      "token": await Common.getSharedPref("token"),
    });
    try {
      var response = await _dio.post(
          "${await Config.getUrl()}add_new_whatsapp_contact",
          data: formData);
      if (response.statusCode == 200) {
        AddContactModel addContactModel =
            AddContactModel.fromJson(response.data);
        return addContactModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      // print("Exception: $e");
    } finally {}
  }

  static officialMessage(groupId, page, pageSize) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}official_whatsapp_messages",
          queryParameters: {
            "group_id": groupId,
            "token": await Common.getSharedPref("token"),
            "pageNo": page,
            "pageSize": pageSize,
          });
      if (response.statusCode == 200) {
        OfficialMessageModel officialMessageModel =
            OfficialMessageModel.fromJson(response.data);
        return officialMessageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static officialMessageCampaigns(groupId, page, pageSize) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}get_campaigns_messages",
          queryParameters: {
            "group_id": groupId,
            "token": await Common.getSharedPref("token"),
            "pageNo": page,
            "pageSize": pageSize,
          });
      if (response.statusCode == 200) {
        CampaignsOfficialMessageModel officialMessageModel =
            CampaignsOfficialMessageModel.fromJson(response.data);
        return officialMessageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log("Exception: $e");
    } finally {}
  }

  static socketChat(String groupId) async {
    try {
      var formData = FormData.fromMap({
        "group_id": groupId,
        "token": await Common.getSharedPref("token"),
      });
      var response = await _dio
          .post("${await Config.getUrl()}getWhatsappMessage", data: formData);

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static socketCampaign(String groupId) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}official_whatsapp_messages",
          queryParameters: {
            "group_id": groupId,
            "token": await Common.getSharedPref("token"),
          });
      if (response.statusCode == 200) {
        List<CampaignMessage> socket =
            CampaignMessage.fromJson(response.data) as List<CampaignMessage>;
        return socket;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static getTemplate() async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}get_official_whatsapp_templates",
          queryParameters: {
            "token": await Common.getSharedPref("token"),
          });
      if (response.statusCode == 200) {
        TemplateModel templateModel = TemplateModel.fromJson(response.data);
        return templateModel;
      } else if (response.statusCode == 500) {
      } else {}
    } finally {}
  }

  static getTemplateContent(templateId) async {
    try {
      var response = await _dio.get(
          "${await Config.getUrl()}get_whatsapp_template_message_data",
          queryParameters: {
            "template_id": templateId,
            "token": await Common.getSharedPref("token"),
          });

      if (response.statusCode == 200) {
        TemplateContentModel templateContentMoel =
            TemplateContentModel.fromJson(response.data);
        return templateContentMoel;
      } else if (response.statusCode == 500) {
      } else {}
    } finally {}
  }

  static sendTemplateMessage(groupId, format, templateName, language, template,
      fileName, isFile, type, List argList) async {
    try {
      // log(jsonEncode(argList).toString());
      var formData = FormData.fromMap({
        "group_id": groupId,
        'format': format,
        'template_name': templateName,
        'language': language,
        'template': template,
        'fileName': type == "file_manager" || isFile == false
            ? fileName
            : await MultipartFile.fromFile(fileName),
        'type': type,
        'is_file': isFile.toString(),
        "token": await Common.getSharedPref("token"),
        "arg_list": jsonEncode(argList)
      });
      var response = await _dio.post(
          "${await Config.getUrl()}sendTemplatewhatsappMessage",
          data: formData);
      if (response.statusCode == 200) {
        SendTemplateMesaageModel sendTemplateMesaageModel =
            SendTemplateMesaageModel.fromJson(response.data);
        return sendTemplateMesaageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log("Exception: $e");
    }
  }

  static sendMessage(
    groupId,
    messageData,
    fileName,
    isImage,
  ) async {
    var formData = FormData.fromMap({
      "group_id": groupId,
      'message_data': messageData,
      'fileName': isImage == true ? await MultipartFile.fromFile(fileName) : '',
      'is_image': isImage,
      "token": await Common.getSharedPref("token"),
    });

    try {
      var response = await _dio.post("${await Config.getUrl()}sendMessage",
          data: formData);

      if (response.statusCode == 200) {
        SendMesaageModel sendMesaageModel =
            SendMesaageModel.fromJson(response.data);
        return sendMesaageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      // print("Exception: $e");
    } finally {}
  }

  static sendMessageFile(groupId, messageData, fileName) async {
    var formData = FormData.fromMap({
      "group_id": groupId,
      'message_data': messageData,
      'fileName': fileName,
      "token": await Common.getSharedPref("token"),
    });

    try {
      var response = await _dio.post("${await Config.getUrl()}sendMessageFiles",
          data: formData);

      if (response.statusCode == 200) {
        SendMesaageModel sendMesaageModel =
            SendMesaageModel.fromJson(response.data);
        return sendMesaageModel;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      // print("Exception: $e");
    } finally {}
  }

  static Future getTemplateMedia(format) async {
    var params = {
      "token": await Common.getSharedPref("token"),
      "fileType": format
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getMediaFiles",
          queryParameters: params);
      MediaModel model = MediaModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogUploadPermission(body) async {
    try {
      var result = await _dio.get("${await Config.getUrl()}call_log_checking",
          queryParameters: body);
      if (kDebugMode) {
        print(result);
      }
      CallLogUploadPermissionModel model =
          CallLogUploadPermissionModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future callLogUploadPermissionUpdate(body) async {
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}update_user_call_permission",
          queryParameters: body);
      if (kDebugMode) {
        print(result);
      }
      CallLogUploadPermissionUpdateModel model =
          CallLogUploadPermissionUpdateModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  static Future officialWhatsAppConfigure() async {
    var params = {
      "token": await Common.getSharedPref("token"),
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}official_whatsapp_config",
          queryParameters: params);
      OfficialWhatsappConfigeModel model =
          OfficialWhatsappConfigeModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }
  /*  Complaints Ansar */

  static Future<GetModel?> getComplaintDetails() async {
    // log(await Common.getSharedPref("token"));
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}getComplaintDetails", data: formData);

      if (response.statusCode == 200) {
        GetModel getModel = GetModel.fromJson(response.data);
        return getModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<PostModel?> postComplaint(
    List type,
    String compBy,
    String custName,
    String custPhone,
    String custEmail,
    String date,
    String description,
    // List compAgainst,
    remark,
    String status,
    List nature,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref("token"),
      "complaint_type": jsonEncode(type),
      "complaint_report_by": compBy,
      "coustmer_name": custName,
      "coustmer_contact_number": custPhone,
      "coustmer_email": custEmail,
      "incident_date": date,
      "complaint_description": description,
      // "complaint_agianst": jsonEncode(compAgainst),
      "employee_remarks": jsonEncode(remark),
      "complaint_status": status,
      "complaint_nature": jsonEncode(nature),
    });

    try {
      final response = await _dio.post("${await Config.getUrl()}postComplaint",
          data: formData);
      if (response.statusCode == 200) {
        PostModel postModel = PostModel.fromJson(response.data);
        return postModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<ListModel?> getList(String fDate, String tDate, String compType,
      String repBy, String comNature) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "from_date": fDate,
      "to_date": tDate,
      "complaint_type": compType,
      "reported_by": repBy,
      "complaint_nature": comNature,
    });

    try {
      //log("${await Config.getUrl()}");
      final response = await _dio.post("${await Config.getUrl()}getComplaints",
          data: formData);

      if (response.statusCode == 200) {
        ListModel listModel = ListModel.fromJson(response.data);
        return listModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<AddItemModel?> addItems(String status, String value) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "status": status,
      "field_val": value
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}postComplaintStatus", data: formData);

      if (response.statusCode == 200) {
        AddItemModel addItemModel = AddItemModel.fromJson(response.data);
        return addItemModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<DetailsModel?> getDetails(String compId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_id": compId,
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}getComplaintById", data: formData);

      if (response.statusCode == 200) {
        DetailsModel detailsModel = DetailsModel.fromJson(response.data);
        return detailsModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<PostRemarkModel?> postRemark(
      String compId, String remark) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_id": compId,
      "remarks": remark
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}postComplaintRemarks", data: formData);

      if (response.statusCode == 200) {
        PostRemarkModel postRemarkModel =
            PostRemarkModel.fromJson(response.data);
        return postRemarkModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<DeleteModel?> deleteComplaint(String compId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_id": compId,
    });
    try {
      final response = await _dio
          .post("${await Config.getUrl()}deleteComplaint", data: formData);

      if (response.statusCode == 200) {
        DeleteModel deleteModel = DeleteModel.fromJson(response.data);
        return deleteModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<UpdateComplaintModel?> updateComplaint(
      List type,
      String compBy,
      String custName,
      String custPhone,
      String custEmail,
      String date,
      String description,
      // List compAgainst,
      remark,
      String status,
      List nature,
      String compId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "complaint_type": jsonEncode(type),
      "complaint_report_by": compBy,
      "coustmer_name": custName,
      "coustmer_contact_number": custPhone,
      "coustmer_email": custEmail,
      "incident_date": date,
      "complaint_description": description,
      // "complaint_agianst": jsonEncode(compAgainst),
      "employee_remarks": jsonEncode(remark),
      "complaint_status": status,
      "complaint_nature": jsonEncode(nature),
      "complaint_id": compId
    });

    try {
      final response = await _dio
          .post("${await Config.getUrl()}updateComplaint", data: formData);
      if (response.statusCode == 200) {
        UpdateComplaintModel complaintUpdateModel =
            UpdateComplaintModel.fromJson(response.data);
        return complaintUpdateModel;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  ////// complaints ends  ///////

  ///// Staff Dashboard //////

  static Future<UserDashboardModel?> getStaffDashboard(
      String userId, String type) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "type": type,
      "user_id": userId
    };
    try {
      final response = await _dio.get(
          "${await Config.getUrl()}/view_staff_dashboard",
          queryParameters: params);

      if (response.statusCode == 200) {
        UserDashboardModel? userDashboardModel =
            UserDashboardModel.fromJson(response.data);
        return userDashboardModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<StaffCalldetailsModel?> getStaffCallDetails(
      String userId, String fDate, String tDate) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "from_date": fDate,
      "to_date": tDate,
      "user_id": userId
    };
    try {
      final response = await _dio.get(
          "${await Config.getUrl()}/view_staff_call_details",
          queryParameters: params);

      if (response.statusCode == 200) {
        StaffCalldetailsModel? staffCalldetailsModel =
            StaffCalldetailsModel.fromJson(response.data);
        return staffCalldetailsModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //// Renewal Management ////

  static Future renewalDashboard() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}renewalDashboard",
          data: formData);
      if (result.statusCode == 200) {
        RenewalDashboardModel response =
            RenewalDashboardModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalDetails() async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getAddRenewalData",
          data: formData);
      if (result.statusCode == 200) {
        RenewalDetailslModel response =
            RenewalDetailslModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getAddRenewalFollowUpDetails(renewalId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": renewalId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getAddRenewalFollowUpDetails",
          data: formData);
      if (result.statusCode == 200) {
        RenewalFollowupDetailsModel response =
            RenewalFollowupDetailsModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalDetailsById(String id, String type) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_type": type,
      "renewal_id": id
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getRenewalById",
          data: formData);
      if (result.statusCode == 200) {
        RenewalByIdModel response = RenewalByIdModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postExistingQuick(
      renewalProducts,
      clientId,
      cost,
      templateId,
      startDate,
      endDate,
      remarks,
      branchId,
      isPaid,
      actualCost,
      createInvoice,
      checkIdVal) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_product": jsonEncode(renewalProducts),
      "client_id": clientId,
      "cost": cost,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "is_paid": isPaid,
      "actual_cost": actualCost,
      "create_invoice": createInvoice,
      "check_id_val": checkIdVal
    });

    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postexistingCustomerRenewal",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postNewQuick(
      isPaid,
      branchId,
      countryCode,
      contactNo,
      whatsappCountryCode,
      whatsappContactNo,
      clientName,
      address1,
      address2,
      address3,
      postOffice,
      pincode,
      gstNum,
      remarks,
      products,
      startDate,
      endDate,
      cost,
      email,
      actualCost,
      createInvoice,
      templateId,
      checkIdVal) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "is_paid": isPaid,
      "branch_id": branchId ?? "",
      "country_code": countryCode,
      "contact_no": contactNo,
      "whatsapp_country_code": whatsappCountryCode,
      "whatsapp_contact_no": whatsappContactNo,
      "client_name": clientName,
      "address": address1,
      "address2": address2,
      "address3": address3,
      "post_office": postOffice,
      "pincode": pincode,
      "gst_num": gstNum,
      "remarks": remarks,
      "renewal_product": jsonEncode(products),
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "cost": cost,
      "email_id ": email,
      "actual_cost": actualCost,
      "create_invoice": createInvoice,
      "check_id_val": checkIdVal
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postNewCustomerRenewal",
          data: formData);
      if (result.statusCode == 200) {
        AddCustomerModel response = AddCustomerModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postExistingCustom(
      renewalProducts,
      clientId,
      templateId,
      startDate,
      endDate,
      remarks,
      branchId,
      actualCost,
      checkIdVal,
      invoiceNum,
      invoiceDate,
      invoiceSl,
      subTotal,
      tax,
      discount,
      shipping,
      totalAmount,
      paidAmount,
      payStatus,
      payMethod,
      collectedStaff) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "product_details": jsonEncode(renewalProducts),
      "client_id": clientId,
      "reminder_template": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "actual_cost": actualCost,
      "check_id_val": checkIdVal,
      "invoice_number": invoiceNum,
      "invoice_date": invoiceDate,
      "invoice_sl_number": invoiceSl,
      "sub_total": subTotal,
      "estimated_tax": tax,
      "discount_amount": discount,
      "shipping_amount": shipping,
      "total_amount_paid": totalAmount,
      "amount_paid_customer": paidAmount,
      "payment_status": payStatus,
      "payment_method": payMethod,
      "collected_staff": collectedStaff,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postExistingCustomRenewal",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postNewCustom(
      branchId,
      countryCode,
      contactNo,
      whatsappCountryCode,
      whatsappContactNo,
      clientName,
      address1,
      address2,
      address3,
      postOffice,
      pincode,
      gstNum,
      remarks,
      renewalProducts,
      startDate,
      endDate,
      cost,
      email,
      actualCost,
      templateId,
      checkIdVal,
      invoiceNum,
      invoiceDate,
      invoiceSl,
      subTotal,
      tax,
      discount,
      shipping,
      totalAmount,
      paidAmount,
      payStatus,
      payMethod,
      collectedStaff) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "branch_id": branchId ?? "",
      "country_code": countryCode,
      "contact_no": contactNo,
      "whatsapp_country_code": whatsappCountryCode,
      "whatsapp_contact_no": whatsappContactNo,
      "client_name": clientName,
      "address": address1,
      "address2": address2,
      "address3": address3,
      "post_office": postOffice,
      "pincode": pincode,
      "gst_num": gstNum,
      "remarks": remarks,
      "product_details": jsonEncode(renewalProducts),
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "email_id ": email,
      "actual_cost": actualCost,
      "check_id_val": checkIdVal,
      "invoice_number": invoiceNum,
      "invoice_date": invoiceDate,
      "invoice_sl_number": invoiceSl,
      "sub_total": subTotal,
      "estimated_tax": tax,
      "discount_amount": discount,
      "shipping_amount": shipping,
      "total_amount_paid": totalAmount,
      "amount_paid_customer": paidAmount,
      "payment_status": payStatus,
      "payment_method": payMethod,
      "collected_staff": collectedStaff,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postCustomRenewal",
          data: formData);
      if (result.statusCode == 200) {
        AddCustomerModel response = AddCustomerModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future renewalList(page, pageSize, clientId, fromDate, toDate,
      daysToExpire, String searchKey, searchMonth, String expireIn) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "page_size": pageSize,
      "client_id": clientId,
      "from_date": fromDate ?? "",
      "to_date": toDate ?? "",
      "days_to_expire": daysToExpire,
      "search_key": searchKey,
      "search_month": searchMonth,
      "expiry_in_days": expireIn
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}getAllRenewalReports", data: formData);
      if (result.statusCode == 200) {
        RenewalListModel response = RenewalListModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateCustomRenewal(
      rowId,
      customerId,
      branchId,
      startDate,
      endDate,
      renewalType,
      renewalProduct,
      templateId,
      remarks,
      invoiceId,
      paymentStatus,
      paymentMethod,
      cartId,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      totalAmount,
      paidAmount,
      invoiceDate,
      collectedStaff) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_type": renewalType,
      "cart_id": cartId,
      "row_id": rowId,
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
      "renewal_product": jsonEncode(renewalProduct),
      "customer_id": customerId,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "invoice_id": invoiceId,
      "invoice_date": invoiceDate,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "total_amount_paid": totalAmount,
      "cost": totalAmount,
      "amount_paid_customer": paymentStatus == "unpaid" ? "0" : paidAmount,
      "payment_status": paymentStatus ?? "",
      "payment_method": paymentMethod ?? "",
      "collected_staff": collectedStaff ?? "",
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}updateRenewalDetails", data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateQuickRenewal(
    rowId,
    renewalType,
    customerId,
    branchId,
    startDate,
    endDate,
    renewalProduct,
    templateId,
    remarks,
    cost,
    actualCost,
    isPaid,
    createInvoice,
    invoiceId,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
      "renewal_type": renewalType,
      "create_invoice": createInvoice,
      "row_id": rowId,
      "is_paid": isPaid,
      "renewal_product": jsonEncode(renewalProduct),
      "customer_id": customerId,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "actual_cost": actualCost,
      "cost": cost,
      "invoice_id": invoiceId,
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}updateRenewalDetails", data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future hideRenewal(String recordId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "record_id": recordId});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}hideRenewalCustomer", data: formData);
      if (result.statusCode == 200) {
        HideModel response = HideModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future hiddenList(
      page, pageSize, clientId, fromDate, toDate, daysToExpire) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "page_size": pageSize,
      "client_id": clientId,
      "from_date": fromDate ?? "",
      "to_date": toDate ?? "",
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getRenewalHidden",
          data: formData);
      if (result.statusCode == 200) {
        HiddenListModel response = HiddenListModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future paymentReport(
      page, pageSize, clientId, fromDate, toDate, daysToExpire) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "page": page,
      "page_size": pageSize,
      "client_id": clientId,
      "from_date": fromDate ?? "",
      "to_date": toDate ?? "",
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalPaymentReport",
          data: formData);
      if (result.statusCode == 200) {
        PaymentReportModel response = PaymentReportModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postRenewQuick(
    branchId,
    rowId,
    startDate,
    endDate,
    cost,
    remarks,
    renewalProduct,
    customerId,
    isPaid,
    createInvoice,
    renewalType,
    templateId,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "branch_id": branchId ?? "",
      "row_id": rowId,
      "start_date": startDate,
      "end_date": endDate,
      "cost": cost,
      "remarks": remarks,
      "customer_id": customerId,
      "is_paid": isPaid,
      "create_invoice": createInvoice,
      "renewal_product": jsonEncode(renewalProduct),
      "renewal_type": renewalType,
      "template_id": templateId,
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
    });
    log(jsonEncode(renewalProduct));

    try {
      var result = await _dio.post("${await Config.getUrl()}postRenewDetails",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postRenewCustom(
    rowId,
    customerId,
    branchId,
    startDate,
    endDate,
    renewalType,
    renewalProduct,
    templateId,
    remarks,
    invoiceId,
    paymentStatus,
    paymentMethod,
    cartId,
    subTotal,
    estimatedTax,
    discountAmount,
    shippingAmount,
    totalAmount,
    paidAmount,
    invoiceDate,
    collectedStaff,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_type": renewalType,
      "row_id": rowId,
      "check_id_val": DateTime.now().millisecondsSinceEpoch,
      "renewal_product": jsonEncode(renewalProduct),
      "customer_id": customerId,
      "template_id": templateId,
      "start_date": startDate,
      "end_date": endDate,
      "remarks": remarks,
      "branch_id": branchId ?? "",
      "invoice_id": invoiceId,
      "invoice_date": invoiceDate,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "total_amount_paid": totalAmount,
      "amount_paid_customer": paidAmount,
      "payment_status": paymentStatus ?? "",
      "payment_method": paymentMethod ?? "",
      "collected_staff": collectedStaff ?? "",
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postRenewDetails",
          data: formData);
      if (result.statusCode == 200) {
        PostRenewalModel response = PostRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future rivertRenewal(String recordId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "record_id": recordId});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}revertRenewalClient", data: formData);
      if (result.statusCode == 200) {
        RivertModel response = RivertModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteRenewalClient(String recordId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "record_id": recordId});
    try {
      var result = await _dio
          .post("${await Config.getUrl()}deleteRenewalClient", data: formData);
      if (result.statusCode == 200) {
        DeleteRenewalModel response = DeleteRenewalModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future viewHistory(String id) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": id,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalReminderHistory",
          data: formData);
      if (result.statusCode == 200) {
        ReminderHistoryModel response =
            ReminderHistoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future isCustomerExists(String id, String phoneNumber) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "customer_id": id,
      "phone_number": "91$phoneNumber"
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}isCustomerExists",
          data: formData);
      if (result.statusCode == 200) {
        IsCustomerExistModel response =
            IsCustomerExistModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getRenewalReminderMessage(String renId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": renId,
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getRenewalReminderMessage",
          data: formData);
      if (result.statusCode == 200) {
        RenewalTemplateModel response =
            RenewalTemplateModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postReminder(String renId, String contactNumber, templateType,
      templateName, templateId, customerId, messageContent) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "row_id": renId,
      "contact_no": contactNumber,
      "template_type": templateType,
      "template_name": templateName,
      "template_id": templateId,
      "medium": "official",
      "customer_id": customerId,
      "message_content": messageContent
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}sendRenewalReminder", data: formData);
      if (result.statusCode == 200) {
        PostReminderModel response = PostReminderModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future bulkReminder(List recordId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "renewal_id": jsonEncode(recordId),
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}sendBulkReminder",
          data: formData);
      if (result.statusCode == 200) {
        BulkRemindModel response = BulkRemindModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postRenewalFollowup(
      token,
      leadStatusId,
      nextFollowupDate,
      cost,
      leadId,
      remarks,
      callMasterId,
      calledDate,
      customerId,
      checked,
      timeBefore,
      callResponseId,
      reasonId,
      createSales,
      invoiceDate,
      productList,
      reminderTemplate,
      totalAmount,
      startDate,
      endDate,
      paymentStatus,
      subTotal,
      estimatedTax,
      discountAmount,
      shippingAmount,
      paymentMethod,
      paidAmount,
      collectedStaff) async {
    var formData = FormData.fromMap({
      "token": token,
      "next_followup_date": nextFollowupDate,
      "call_result_id": callResponseId,
      "lead_id": leadId,
      "lead_status": leadStatusId,
      "cost": cost,
      "remarks": remarks,
      "renewal_id": callMasterId,
      "called_date": calledDate,
      "customer_id": customerId,
      "reminder": checked,
      "time_before": timeBefore,
      "reason_id": reasonId,
      "create_sales": createSales,
      "invoice_date": invoiceDate,
      "product_list": leadStatusId == '2' ? "" : jsonEncode(productList),
      "follow_up_products": leadStatusId == '2' ? jsonEncode(productList) : "",
      "reminder_template": reminderTemplate,
      "total_amount_paid": totalAmount,
      "start_date": startDate,
      "end_date": endDate,
      "payment_status": paymentStatus,
      "sub_total": subTotal,
      "estimated_tax": estimatedTax,
      "discount_amount": discountAmount,
      "shipping_amount": shippingAmount,
      "payment_method": paymentMethod,
      "amount_paid_customer": paidAmount,
      "collected_staff": collectedStaff,
    });

    try {
      var result = await _dio
          .post("${await Config.getUrl()}postRenewalFollowup", data: formData);
      AddLeadFollowupModel model = AddLeadFollowupModel.fromJson(result.data);
      return model;
    } catch (e) {
      log("error: $e");
    }
  }

  /// product mannagement ///

  static Future getProductCategory() async {
    var formData =
        FormData.fromMap({"token": await Common.getSharedPref('token')});
    try {
      var result = await _dio.post("${await Config.getUrl()}getProductCategory",
          data: formData);
      if (result.statusCode == 200) {
        ProductCategoriesModel response =
            ProductCategoriesModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getProductSubCategory(String id) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "category_id": id});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}getProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        SubCategoriesModel response = SubCategoriesModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getProductLists(String subId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "sub_category_id": subId
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getProductLists",
          data: formData);
      if (result.statusCode == 200) {
        ProductListModel response = ProductListModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postProducts(
    String contentId,
    String categoryId,
    String subCategoryId,
    String productName,
    String productCode,
    String productMrp,
    String noOfDays,
    String remindBefore,
    String sellingPrice,
    String taxPercent,
    String totalAmount,
    String description,
    productImage,
  ) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "content_id": contentId,
      "category_id": categoryId,
      "sub_category_id": subCategoryId,
      "product_name": productName,
      "product_code": productCode,
      "product_mrp": productMrp,
      "no_of_days": noOfDays,
      "remind_before": remindBefore,
      "selling_price": sellingPrice,
      "tax_percent": taxPercent,
      "total_amount": totalAmount,
      "description": description,
      "product_image": productImage == null
          ? ""
          : await MultipartFile.fromFile(productImage.toString())
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}postProduct",
          data: formData);
      if (result.statusCode == 200) {
        PostProductModel response = PostProductModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getProductById(String id) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": id});
    try {
      var result = await _dio.post("${await Config.getUrl()}getProductById",
          data: formData);
      if (result.statusCode == 200) {
        ProdectsByIdModel response = ProdectsByIdModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateProduct(
      String contentId,
      String categoryId,
      String subCategoryId,
      String productName,
      String productCode,
      String productMrp,
      String noOfDays,
      String remindBefore,
      String sellingPrice,
      String taxPercent,
      String totalAmount,
      String description,
      productImage,
      String productId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "content_id": contentId,
      "category_id": categoryId,
      "sub_category_id": subCategoryId,
      "product_name": productName,
      "product_code": productCode,
      "product_mrp": productMrp,
      "no_of_days": noOfDays,
      "remind_before": remindBefore,
      "selling_price": sellingPrice,
      "tax_percent": taxPercent,
      "total_amount": totalAmount,
      "description": description,
      "product_image": productImage == null
          ? ""
          : await MultipartFile.fromFile(productImage.toString()),
      "row_id": productId
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}updateProduct",
          data: formData);
      if (result.statusCode == 200) {
        PostProductModel response = PostProductModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteProduct(String id) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": id});
    try {
      var result = await _dio.post("${await Config.getUrl()}deleteProduct",
          data: formData);
      if (result.statusCode == 200) {
        DeleteProductModel response = DeleteProductModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postProductCategory(String categoryName) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_name": categoryName
    });
    try {
      var result = await _dio
          .post("${await Config.getUrl()}postProductCategory", data: formData);
      if (result.statusCode == 200) {
        PostProductCategoryModel response =
            PostProductCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateProductCategory(String categoryName, String rowId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_name": categoryName,
      "row_id": rowId
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}updateProductCategory",
          data: formData);
      if (result.statusCode == 200) {
        UpdateProductCategoryModel response =
            UpdateProductCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteProductCategory(String rowId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": rowId});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}deleteProductCategory",
          data: formData);
      if (result.statusCode == 200) {
        DeleteProductCategoryModel response =
            DeleteProductCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postProductSubCategory(
      String categoryId, String subCategory) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_id": categoryId,
      "sub_category": subCategory
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}postProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        PostProductSubCategoryModel response =
            PostProductSubCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateProductSubCategory(
      String subCategory, String rowId, String catId) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "category_id": catId,
      "sub_category": subCategory,
      "row_id": rowId
    });
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}updateProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        UpdateProductSubCategoryModel response =
            UpdateProductSubCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteProductSubCategory(String rowId) async {
    var formData = FormData.fromMap(
        {"token": await Common.getSharedPref('token'), "row_id": rowId});
    try {
      var result = await _dio.post(
          "${await Config.getUrl()}deleteProductSubCategory",
          data: formData);
      if (result.statusCode == 200) {
        DeleteProductSubCategoryModel response =
            DeleteProductSubCategoryModel.fromJson(result.data);
        return response;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  /// product mannagement ///

  /// whatsapp Profile

  static addCampaignContact(
    String campaignId,
    String contactName,
    String countryCode,
    String contactNumber,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "campaign_id": campaignId,
        "contact_name": contactName,
        "country_code": countryCode,
        "contact_number": contactNumber,
      });
      var response = await _dio.post(
          "${await Config.getUrl()}add_contact_to_campaign",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel addContact =
            CampaignSampleModel.fromJson(response.data);
        return addContact;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static editGroupName(
    String groupId,
    String groupName,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "group_id": groupId,
        "group_name": groupName,
      });
      var response = await _dio.post("${await Config.getUrl()}edit_campaign",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel campaignEdit =
            CampaignSampleModel.fromJson(response.data);
        return campaignEdit;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static removeContactCampaign(
    String id,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "id": id,
      });
      var response = await _dio.post(
          "${await Config.getUrl()}remove_contact_from_campaign",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel removeContact =
            CampaignSampleModel.fromJson(response.data);
        return removeContact;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static deleteWhatsAppGroup(
    String id,
  ) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "group_id": id,
      });
      var response = await _dio.post("${await Config.getUrl()}delete_group",
          data: formData);
      if (response.statusCode == 200) {
        CampaignSampleModel deleteGroup =
            CampaignSampleModel.fromJson(response.data);
        return deleteGroup;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  static viewMessageStatus(String id, String messageId) async {
    try {
      var formData = FormData.fromMap({
        "token": await Common.getSharedPref('token'),
        "group_id": id,
        "message_id": messageId
      });
      var response = await _dio
          .post("${await Config.getUrl()}view_message_status", data: formData);
      if (response.statusCode == 200) {
        MessageViewStatusModel getResponse =
            MessageViewStatusModel.fromJson(response.data);
        return getResponse;
      } else if (response.statusCode == 500) {
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  ///------ Expense ------///
  static Future expenseList(
      fdate, tdate, page, pageSize, catId, staffId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "from_date": fdate,
      "to_date": tdate,
      "page": page,
      "page_size": pageSize,
      "category_id": catId,
      "staff_id": staffId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}expense_list",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpenseListModel model = ExpenseListModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future expenseMasterData() async {
    var params = {
      "token": await Common.getSharedPref('token'),
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}expense_master_data",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpenseMasterData model = ExpenseMasterData.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future postExpense(
    String catId,
    String amount,
    String fromAcc,
    String toAcc,
    String date,
    String remarks,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryId": catId,
      "amount": amount,
      "fromAccount": fromAcc,
      "toPerson": toAcc,
      "date": date,
      "remarks": remarks,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}add_expense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensePostModel model = ExpensePostModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateExpense(
    String expId,
    String catId,
    String amount,
    String fromAcc,
    String toAcc,
    String date,
    String remarks,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "cmpExpId": expId,
      "categoryId": catId,
      "amount": amount,
      "fromAccount": fromAcc,
      "toPerson": toAcc,
      "date": date,
      "remarks": remarks,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}edit_expense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensePostModel model = ExpensePostModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteExpense(
    String expId,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "cmpnyExId": expId,
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}delete_expense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensePostModel model = ExpensePostModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future expenseCategoryList() async {
    var params = {
      "token": await Common.getSharedPref('token'),
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}getPendingExpense",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpenseCategoryList model = ExpenseCategoryList.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future addExpenseCategory(
    String cat,
  ) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryName": cat,
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_add",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensePostModel model = ExpensePostModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future updateExpenseCategory(String cat, String catId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryName": cat,
      "categoryId": catId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_edit",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensePostModel model = ExpensePostModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future deleteExpenseCategory(String catId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "categoryId": catId
    };
    try {
      var result = await _dio.get(
          "${await Config.getUrl()}expense_category_delete",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensePostModel model = ExpensePostModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future expenseHistory(String expId) async {
    var params = {
      "token": await Common.getSharedPref('token'),
      "expense_id": expId
    };
    try {
      var result = await _dio.get("${await Config.getUrl()}expense_history",
          queryParameters: params);
      if (kDebugMode) {}
      if (result.statusCode == 200) {
        ExpensehistoryModel model = ExpensehistoryModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future accountsDashboard(fDate, tdate) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "fromDate": fDate,
      "toDate": tdate
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}expense_dashboard",
          data: formData);
      if (result.statusCode == 200) {
        AccountDashboardModel model =
            AccountDashboardModel.fromJson(result.data);
        return model;
      }
    } catch (e) {
      log("error: $e");
    }
  }

  static Future getSearchData(String searchKey) async {
    var formData = FormData.fromMap({
      "token": await Common.getSharedPref('token'),
      "searchKey": searchKey,
    });
    try {
      var result = await _dio.post("${await Config.getUrl()}getSearchData",
          data: formData);
      if (result.statusCode == 200) {
        SearchDataModel model = SearchDataModel.fromJson(result.data);
        return model;
      } 
    } catch (e) {
      log("error: $e");
    }
  }
}
