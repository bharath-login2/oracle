class UserPermissionModel {
  Data? data;
  bool? status;
  String? message;

  UserPermissionModel({this.data, this.status, this.message});

  UserPermissionModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? createStaff;
  String? viewStaff;
  String? updateStaff;
  String? deleteStaff;
  String? viewStaffReport;
  String? createStaffDesignation;
  String? viewStaffDesignation;
  String? updateStaffDesignation;
  String? deleteStaffDesignation;
  String? updateStaffPassword;
  String? updateStaffPermission;
  String? createLead;
  String? viewLead;
  String? updateLead;
  String? deleteLead;
  String? createLeadCategory;
  String? viewLeadCategory;
  String? updateLeadCategory;
  String? deleteLeadCategory;
  String? viewLeadReport;
  String? viewWhatsappSettings;
  String? updateWhatsappSettings;
  String? createFacebookSettings;
  String? updateFacebookSettings;
  String? deleteFacebookSettings;
  String? createLeadImports;
  String? cloudCall;
  String? accessCallHistory;
  String? accessCallRecording;
  String? fileManager;
  String? phoneCallLog;
  String? createFile;
  String? openFile;
  String? renameFile;
  String? deleteFile;
  String? downloadFile;

  Data(
      {this.createStaff,
        this.viewStaff,
        this.updateStaff,
        this.deleteStaff,
        this.viewStaffReport,
        this.createStaffDesignation,
        this.viewStaffDesignation,
        this.updateStaffDesignation,
        this.deleteStaffDesignation,
        this.updateStaffPassword,
        this.updateStaffPermission,
        this.createLead,
        this.viewLead,
        this.updateLead,
        this.deleteLead,
        this.createLeadCategory,
        this.viewLeadCategory,
        this.updateLeadCategory,
        this.deleteLeadCategory,
        this.viewLeadReport,
        this.viewWhatsappSettings,
        this.updateWhatsappSettings,
        this.createFacebookSettings,
        this.updateFacebookSettings,
        this.deleteFacebookSettings,
        this.createLeadImports,
        this.cloudCall,
        this.accessCallHistory,
        this.accessCallRecording,
        this.fileManager,
        this.phoneCallLog,
        this.createFile,
        this.openFile,
        this.renameFile,
        this.deleteFile,
        this.downloadFile});

  Data.fromJson(Map<String, dynamic> json) {
    createStaff = json['create_staff'];
    viewStaff = json['view_staff'];
    updateStaff = json['update_staff'];
    deleteStaff = json['delete_staff'];
    viewStaffReport = json['view_staff_report'];
    createStaffDesignation = json['create_staff_designation'];
    viewStaffDesignation = json['view_staff_designation'];
    updateStaffDesignation = json['update_staff_designation'];
    deleteStaffDesignation = json['delete_staff_designation'];
    updateStaffPassword = json['update_staff_password'];
    updateStaffPermission = json['update_staff_permission'];
    createLead = json['create_lead'];
    viewLead = json['view_lead'];
    updateLead = json['update_lead'];
    deleteLead = json['delete_lead'];
    createLeadCategory = json['create_lead_category'];
    viewLeadCategory = json['view_lead_category'];
    updateLeadCategory = json['update_lead_category'];
    deleteLeadCategory = json['delete_lead_category'];
    viewLeadReport = json['view_lead_report'];
    viewWhatsappSettings = json['view_whatsapp_settings'];
    updateWhatsappSettings = json['update_whatsapp_settings'];
    createFacebookSettings = json['create_facebook_settings'];
    updateFacebookSettings = json['update_facebook_settings'];
    deleteFacebookSettings = json['delete_facebook_settings'];
    createLeadImports = json['create_lead_imports'];
    cloudCall = json['cloud_call'];
    accessCallHistory = json['access_call_history'];
    accessCallRecording = json['access_call_recording'];
    fileManager = json['file_manager'];
    phoneCallLog = json['phone_call_log'];
    createFile = json['create_file'];
    openFile = json['open_file'];
    renameFile = json['rename_file'];
    deleteFile = json['delete_file'];
    downloadFile = json['download_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['create_staff'] = this.createStaff;
    data['view_staff'] = this.viewStaff;
    data['update_staff'] = this.updateStaff;
    data['delete_staff'] = this.deleteStaff;
    data['view_staff_report'] = this.viewStaffReport;
    data['create_staff_designation'] = this.createStaffDesignation;
    data['view_staff_designation'] = this.viewStaffDesignation;
    data['update_staff_designation'] = this.updateStaffDesignation;
    data['delete_staff_designation'] = this.deleteStaffDesignation;
    data['update_staff_password'] = this.updateStaffPassword;
    data['update_staff_permission'] = this.updateStaffPermission;
    data['create_lead'] = this.createLead;
    data['view_lead'] = this.viewLead;
    data['update_lead'] = this.updateLead;
    data['delete_lead'] = this.deleteLead;
    data['create_lead_category'] = this.createLeadCategory;
    data['view_lead_category'] = this.viewLeadCategory;
    data['update_lead_category'] = this.updateLeadCategory;
    data['delete_lead_category'] = this.deleteLeadCategory;
    data['view_lead_report'] = this.viewLeadReport;
    data['view_whatsapp_settings'] = this.viewWhatsappSettings;
    data['update_whatsapp_settings'] = this.updateWhatsappSettings;
    data['create_facebook_settings'] = this.createFacebookSettings;
    data['update_facebook_settings'] = this.updateFacebookSettings;
    data['delete_facebook_settings'] = this.deleteFacebookSettings;
    data['create_lead_imports'] = this.createLeadImports;
    data['cloud_call'] = this.cloudCall;
    data['access_call_history'] = this.accessCallHistory;
    data['access_call_recording'] = this.accessCallRecording;
    data['file_manager'] = this.fileManager;
    data['phone_call_log'] = this.phoneCallLog;
    data['create_file'] = this.createFile;
    data['open_file'] = this.openFile;
    data['rename_file'] = this.renameFile;
    data['delete_file'] = this.deleteFile;
    data['download_file'] = this.downloadFile;
    return data;
  }
}