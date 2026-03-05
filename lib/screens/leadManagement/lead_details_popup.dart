import 'dart:developer';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/leadExtraSettings.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart' as af;
import 'package:login2/models/lead_management/callResultResonModel.dart' as cr;
import 'package:login2/models/lead_management/leadSubTypeModel.dart' as lst;
import 'package:login2/models/renewal/renewal_details.dart' as rn;
import 'package:login2/screens/leadManagement/audio_controller.dart';
import 'package:login2/screens/leadManagement/editLeadNew.dart';
import 'package:login2/screens/leadManagement/imageUploadController.dart';
import 'package:login2/service/service.dart';
import '../../core/common.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadDetailsModelAdd.dart';
import '../../models/lead_management/leadMileStoneListModel.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/get_chat_id.dart';
import 'package:login2/models/lead_management/activityModel.dart';
import 'package:login2/models/lead_management/callDataModel.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import '../../models/lead_management/leadProductsModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'add_leads.dart';
import 'add_followup.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:login2/models/lead_management/deleteLeadFollowupModel.dart';
import '../customer/customerDasboard.dart';
import 'editFollowup.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../models/lead_management/fileManagerPermissionModel.dart';
import 'docViewWebView.dart';

class LeadDetailsPopup extends StatefulWidget {
  final String token;
  final bool editLead;
  final bool deleteLead;
  final bool cloudCall;
  final String callMasterId;
  final LeadDeatailsModel leadDetails;
  final LeadDeatailsModelAdd? leadDetailsAdditional;
  final ListFolderNameModel? listFolder;
  final LeadMileStoneListModel? mileStone;
  final af.LeadFollowupData? leadDetailsFollowup;
  final AddLeadCommonDataModel? commonDetails;
  final String pageName;
  final String? status;
  final String? staff;
  final bool? isCalled;
  final String? fromDate;
  final String? toDate;
  final String? category;
  final String? leadType;
  final VoidCallback onDataChanged;

  const LeadDetailsPopup({
    Key? key,
    required this.token,
    required this.editLead,
    required this.deleteLead,
    required this.cloudCall,
    required this.callMasterId,
    required this.leadDetails,
    this.leadDetailsAdditional,
    this.listFolder,
    this.mileStone,
    this.leadDetailsFollowup,
    this.commonDetails,
    required this.pageName,
    this.status,
    this.staff,
    this.isCalled,
    this.fromDate,
    this.toDate,
    this.category,
    this.leadType,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<LeadDetailsPopup> createState() => _LeadDetailsPopupState();
}

class _LeadDetailsPopupState extends State<LeadDetailsPopup>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late TabController _tabController;
  final List<Color> _colors = [
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple,
    Colors.pinkAccent,
    Colors.blueGrey,
  ];

  String? contactPermission;
  String? transferPermission;
  String? cloudCallPermission;
  String? whatsappOfficial;
  String? name;
  String? userId;
  String? phoneCallLogPermission;
  String? callMasterId;
  LeadDeatailsModel? leadDetails;
  LeadDeatailsModelAdd? leadDetailsAdditional;
  FileManagerPermissionModel? fileManagerPermission;
  ListFolderNameModel? listFolder;
  LeadMileStoneListModel? mileStone;
  af.LeadFollowupData? leadDetailsFollowup;
  AddLeadCommonDataModel? commonDetails;
  ActivityMode? activeMode;
  CallHistoryResponse? callDetailsDataS;
  bool isActivityLoading = false;
  bool isCallHistoryLoading = false;

  TextEditingController contactFName = TextEditingController();
  TextEditingController contactLName = TextEditingController();
  TextEditingController contactMobile = TextEditingController();
  TextEditingController transferRemark = TextEditingController();
  TextEditingController folderName = TextEditingController();
  TextEditingController fileName = TextEditingController();
  TextEditingController fileNameEdit = TextEditingController();

  final AudioRecordController audioCreateController =
      Get.put(AudioRecordController());
  final ImageUploadController imageUploadController =
      Get.put(ImageUploadController());

  bool isPlay = false;
  bool isBack = false;
  bool isExpanded = false;
  bool isFile = false;
  bool folderActionEnable = false;
  String path = '';
  String listPath = '';
  String backPath = '';
  String listPathAudio = '';
  String deletePath = '';
  String rawId = '';
  String selectedRawIndex = '';
  String editableName = '';
  bool checked = false;
  PlatformFile? file;
  List checkedItems = [];
  List checkedItemsName = [];

  // Followup form variables
  String callResultId = '2';
  String callResult = 'Followup';
  String callResponseId = '';
  String callResponse = 'Call Response';
  String leadTypeId = '';
  String leadType = 'Lead Category';
  String leadSubTypeId = '';
  String leadSubType = 'Lead Sub Category';
  String priorityId = '2';
  String priority = 'Normal';
  String callResultReasonName = 'Reason';
  String callResultReasonId = '';
  String templateId = "";
  String invoiceNumber = '';
  String typeDuration = "";
  String? createLeadCategory = '';
  String? addLeadSource = '';

  TextEditingController calledDate1 = TextEditingController();
  TextEditingController nextFollowupDate1 = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController callResultVal = TextEditingController();
  TextEditingController callResponseVal = TextEditingController();
  TextEditingController leadTypeVal = TextEditingController();
  TextEditingController leadSubTypeVal = TextEditingController();
  TextEditingController priorityVal = TextEditingController();
  TextEditingController callReasonVal = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController timeBefore = TextEditingController(text: "10");
  TextEditingController renewalRemarks = TextEditingController();
  TextEditingController whatsappLead = TextEditingController();
  TextEditingController emailLead = TextEditingController();

  TextEditingController productDescription = TextEditingController();
  TextEditingController productRate = TextEditingController();
  TextEditingController productQty = TextEditingController(text: "1");
  TextEditingController productTaxPercent = TextEditingController();
  TextEditingController productTaxAmount = TextEditingController();
  TextEditingController productTotalAmount = TextEditingController();
  TextEditingController productTotalAmountTotal = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController shippingCharge = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController reminderTemplate = TextEditingController();
  TextEditingController renProductRate = TextEditingController();
  TextEditingController renProductQty = TextEditingController(text: "1");
  TextEditingController renProductTaxPercent = TextEditingController();
  TextEditingController renProductTaxAmount = TextEditingController();
  TextEditingController renProductTotalAmount = TextEditingController();

  bool isSavingFollowup = false;
  bool isCreatingOrder = false;
  bool isCreatingRenewal = false;
  bool showReminders = false;
  bool createOrder = false;
  bool createRenewal = false;
  bool createCustomer = false;
  LeadSettings? leadSettings;
  bool isLoadingSettings = false;
  bool isDifrent = false;
  bool isMoreDetails = false;
  bool timeOut = false;
  bool result = true;
  bool isChecked = false;
  bool isExpand = false;
  bool isCreatingOrderOnly = false;
  String? creatingOrderFollowupId;

  double totalRenAmount = 0;
  String totalProdAmount = "";

  LeadProductSectionModel? productSectionModel;
  List<LeadProduct> _selectedProducts = [];
  final TextEditingController _productSearchCtrl = TextEditingController();
  List<LeadProduct> _productSearchResults = [];

  rn.RenewalDetailslModel? detailsResponse;
  cr.CallResultResonModel? callResultReason;
  lst.LeadSubTypeModel? leadSubTypeList;
  List<rn.Template> filteredTemplates = [];
  List<rn.Product> productsList = [];
  List<rn.Product> filteredProducts = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> renProducts = [];
  List<ColloctedStaff> filteredStaffList = [];
  List<TargetGroup> filteredTargetsList = [];
  List targetGroups = [];
  List targetGroupNames = [];

  double subTotal = 0.00;
  double subTotalGrand = 0.00;
  double totalTaxAmount = 0.00;
  double allTotal = 0.00;
  dynamic paymentMethod;
  dynamic paymentStatus;
  String productId = "";
  String renProductId = "";
  String staffId = "";
  String staffName = "Choose Staff";
  String productName = "Choose Product";
  String renProductName = "";
  var invoiceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeData();

    _tabController = TabController(length: _getTabCount(), vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedIndex = _tabController.index;
      });
    });

    _loadUserPreferences();

    if (leadDetails != null) {
      contactFName.text = leadDetails!.data!.clientName ?? '';
      contactMobile.text = '+${leadDetails!.data!.contactNumber1 ?? ''}';

      // Initialize followup form defaults
      calledDate1.text = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
      cost.text = leadDetails!.data!.cost ?? '';
      address.text = leadDetails!.data!.address ?? '';
      leadType = leadDetails!.data!.leadCategory ?? '';
      leadTypeId = leadDetails!.data!.leadCategoryId ?? '';
      leadSubType = leadDetails!.data!.leadSubCategory ?? '';
      leadSubTypeId = leadDetails!.data!.leadSubCategoryId ?? '';
      priority = leadDetails!.data!.priority ?? '';
      priorityId = leadDetails!.data!.priorityId ?? '';
    }
  }

  int _getTabCount() {
    int count = 4; // Followup, Activities, Details, Documents
    if (widget.leadDetails.data?.callHistoryPermission == true) count++;
    if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false) count++;
    return count;
  }

  List<String> _getTabLabels() {
    List<String> labels = ['Followup', 'Activities', 'Details', 'Documents'];
    if (widget.leadDetails.data?.callHistoryPermission == true) {
      labels.insert(1, 'Call History');
    }
    if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false) {
      labels.add('Milestones');
    }
    return labels;
  }

  Future<void> _initializeData() async {
    contactPermission = await Common.getSharedPref("getContactPermission");
    transferPermission = await Common.getSharedPref("transferPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    whatsappOfficial = await Common.getSharedPref("officialWhatsapp");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    addLeadSource = await Common.getSharedPref("addLeadSource");

    setState(() {
      callMasterId = widget.callMasterId;
      leadDetails = widget.leadDetails;
      leadDetailsAdditional = widget.leadDetailsAdditional;
      listFolder = widget.listFolder;
      mileStone = widget.mileStone;
      leadDetailsFollowup = widget.leadDetailsFollowup;
      commonDetails = widget.commonDetails;

      if (leadDetails != null) {
        final data = leadDetails!.data!;
        contactFName.text = data.clientName ?? '';
        contactMobile.text = data.contactNumber1 ?? '';
        address.text = data.address ?? '';
        cost.text = data.cost ?? '';
        leadTypeId = data.leadCategoryId ?? '';
        leadType = data.leadCategory ?? 'Lead Category';
        leadSubTypeId = data.leadSubCategoryId ?? '';
        leadSubType = data.leadSubCategory ?? 'Lead Sub Category';
        priorityId = data.priorityId ?? '2';
        priority = data.priority ?? 'Normal';
        whatsappLead.text = data.whatsaAppNumber ?? '';
        emailLead.text = data.emailId ?? '';
      }
    });

    _fetchRenewalDetails();
    _fetchCallResultReason();
    _fetchLeadSubType();
    _fetchActivitiesAndCallHistory();
    _fetchProductSection();
    listFolderList(widget.token, widget.callMasterId, '');
  }

  listFolderList(token, callMasterId, pathValue) async {
    listFolder =
        await HttpService.listFolderAndFiles(token, callMasterId, pathValue);
    if (listFolder != null) {
      fileManagerPermissionFunction(widget.token);
      if (mounted) setState(() {});
    }
  }

  fileManagerPermissionFunction(token) async {
    fileManagerPermission = await HttpService.fileManagerPermission(token);
    if (fileManagerPermission != null) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _fetchProductSection() async {
    final res = await HttpService.leadProductSection();
    if (res != null && mounted) {
      setState(() {
        productSectionModel = res;
        if (leadDetails?.data?.productsOnAdd != null &&
            leadDetails!.data!.productsOnAdd!.isNotEmpty) {
          List<String> ids = leadDetails!.data!.productsOnAdd!.split(',');
          _selectedProducts =
              res.data?.where((p) => ids.contains(p.id.toString())).toList() ??
                  [];
        }
      });
    }
  }

  Future<void> _fetchActivitiesAndCallHistory() async {
    if (widget.leadDetails.data?.callHistoryPermission == true) {
      _fetchCallHistory();
    }
    _fetchActivities();
  }

  Future<void> _fetchCallHistory() async {
    if (!mounted) return;
    setState(() => isCallHistoryLoading = true);
    try {
      final response =
          await HttpService.callDetailsData(widget.token, widget.callMasterId);
      if (mounted) {
        setState(() {
          callDetailsDataS = response;
          isCallHistoryLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching call history: $e");
      if (mounted) setState(() => isCallHistoryLoading = false);
    }
  }

  Future<void> _fetchActivities() async {
    if (!mounted) return;
    setState(() => isActivityLoading = true);
    try {
      final response =
          await HttpService.activityMode(widget.token, widget.callMasterId);
      if (mounted) {
        setState(() {
          activeMode = response?.data;
          isActivityLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching activities: $e");
      if (mounted) setState(() => isActivityLoading = false);
    }
  }

  Future<void> _fetchRenewalDetails() async {
    try {
      final response = await HttpService.getRenewalDetails();
      if (response != null) {
        setState(() {
          detailsResponse = response;
          invoiceNumber = response.data.invoiceNumber.toString();
          productsList = response.data.products;
          filteredTemplates = response.data.template;
          filteredProducts.addAll(productsList);
        });
      }
    } catch (e) {
      log("Error fetching renewal details: $e");
    }
  }

  Future<void> _fetchLeadExtraSettings(String callResultId) async {
    setState(() {
      isLoadingSettings = true;
    });
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
      if (mounted) {
        setState(() {
          isLoadingSettings = false;
          leadSettings = null;
        });
      }
    }
  }

  Future<void> _fetchCallResultReason() async {
    if (callResultId.isNotEmpty) {
      try {
        final response =
            await HttpService.callResultReasonLiat(widget.token, callResultId);
        setState(() {
          callResultReason = response;
        });
      } catch (e) {
        log("Error fetching call result reasons: $e");
      }
    }
  }

  Future<void> _fetchLeadSubType() async {
    if (leadTypeId.isNotEmpty) {
      try {
        final response = await HttpService.leadSubType(leadTypeId);
        setState(() {
          leadSubTypeList = response;
        });
      } catch (e) {
        log("Error fetching lead sub types: $e");
      }
    }
  }

  Future<void> _loadUserPreferences() async {
    contactPermission = await Common.getSharedPref("saveContactPermission");
    transferPermission = await Common.getSharedPref("transferLeads");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    whatsappOfficial = await Common.getSharedPref("officialWhatsApp");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Lead summary card
              SliverToBoxAdapter(child: _buildLeadSummaryCard()),

              // Pinned Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF2a86c9),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2a86c9).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelColor: Colors.grey.shade600,
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        tabAlignment: TabAlignment.start,
                        tabs: _getTabLabels()
                            .map((label) => Tab(
                                  height: 40,
                                  child: Text(label),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildFollowupTab(),
              if (widget.leadDetails.data?.callHistoryPermission == true)
                _buildCallHistoryTab(),
              _buildActivitiesTab(),
              _buildDetailsTab(),
              _buildDocumentsTab(),
              if (widget.mileStone?.data?.milestones?.isNotEmpty ?? false)
                _buildMilestonesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Lead Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadSummaryCard() {
    final data = leadDetails!.data!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.clientName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: data.priorityId == "4"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336)
                                .withOpacity(0.08), // accentRed
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFF44336)
                                    .withOpacity(0.2)), // accentRed
                          ),
                          child: Text(
                            data.leadCategory == null ||
                                    data.leadCategory!.isEmpty
                                ? "General"
                                : data.leadCategory!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFF44336), // accentRed
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(data.priorityId),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.priority ?? 'Normal',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(data.callResultId).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _getStatusColor(data.callResultId)
                              .withOpacity(0.3)),
                    ),
                    child: Text(
                      data.callResult ?? 'New',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(data.callResultId),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (data.leadCategories != null &&
                      data.leadCategories!.length > 1) ...[
                    const SizedBox(height: 8),
                    PopupMenuButton<int>(
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                              border: Border.all(color: Colors.blue.shade200),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        itemBuilder: (context) {
                          return [
                            for (int i = 0;
                                i < data.leadCategories!.length;
                                i++)
                              PopupMenuItem<int>(
                                value: int.parse(data
                                    .leadCategories![i].callMasterId
                                    .toString()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        data.leadCategories![i].isSelected ==
                                                true
                                            ? const Icon(
                                                Icons.done,
                                                size: 20,
                                                color: Colors.green,
                                              )
                                            : const SizedBox(width: 15),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            data.leadCategories![i].leadCategory
                                                .toString(),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: data.leadCategories![i]
                                                          .leadStatus ==
                                                      "New"
                                                  ? Colors.blue
                                                  : data.leadCategories![i]
                                                              .leadStatus ==
                                                          "Follow Up"
                                                      ? Colors.yellow
                                                      : data.leadCategories![i]
                                                                  .leadStatus ==
                                                              "Rejected"
                                                          ? Colors.red
                                                          : const Color
                                                              .fromARGB(
                                                              255, 96, 66, 226),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              data.leadCategories![i].leadStatus
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 7.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 25),
                                            child: Text(
                                              'Staff: ${data.leadCategories![i].staffName.toString()}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              'Created Date: ${data.leadCategories![i].createdDate.toString()}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ];
                        },
                        onSelected: (value) {
                          _refreshData(value.toString());
                        }),
                  ]
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          // Info Grid
          Row(
            children: [
              _buildInfoItem(
                  Icons.phone_android_rounded, data.contactNumber1 ?? 'N/A'),
              const SizedBox(width: 16),
              _buildInfoItem(
                  Icons.person_outline_rounded, data.staffName ?? 'Unassigned'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoItem(
                  Icons.calendar_today_rounded, data.createdDate ?? 'N/A'),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    _getSourceIcon(data.leadSource),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        data.leadSource ?? 'Other',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (data.address?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_rounded,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.address!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () => _handleCallAction(),
                child: _buildActionColumn(
                  icon: Icons.call,
                  label: 'Call',
                  color: Colors.green,
                ),
              ),
              // WhatsApp
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final String? phone = leadDetails?.data?.contactNumber1;
                  if (phone == null) return;
                  if (value == "1") {
                    final whatsappLink = "https://wa.me/$phone";
                    await launchUrl(Uri.parse(whatsappLink));
                  } else if (value == "2") {
                    Common.showProgressDialog(context, "Loading...");
                    try {
                      GetWhatsappChat whatsappGroup =
                          await HttpService.getWhatsappGroupid(
                              leadDetails!.data!.clientName!,
                              leadDetails!.data!.countryCode!,
                              leadDetails!.data!.contactNumber1!);
                      Navigator.pop(context);
                      if (whatsappGroup.status == true) {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  groupId: whatsappGroup.data,
                                  nav: "",
                                ),
                              )).then((_) {
                            widget.onDataChanged();
                          });
                        }
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      log("Error opening official whatsapp: $e");
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: "1", child: Text("Personal WhatsApp")),
                  if (whatsappOfficial == 'true')
                    const PopupMenuItem(
                        value: "2", child: Text("Official WhatsApp")),
                ],
                child: _buildActionColumn(
                  imageAsset: "assets/icons/whatsapp_white.png",
                  label: 'WhatsApp',
                  color: Colors.green,
                  isSolid: true,
                ),
              ),
              // Share
              // InkWell(
              //   onTap: () async {
              //     final String? phone = leadDetails?.data?.contactNumber1;
              //     final String? name = leadDetails?.data?.clientName;
              //       final String? url = leadDetails?.data?.callMasterId;
              //     if (phone == null) return;
              //     final whatsappLink =
              //         "https://wa.me?text=Name: $name\nPhone :$phone";
              //     await launchUrl(Uri.parse(whatsappLink));
              //   },
              //   child: _buildActionColumn(
              //       icon: Icons.share, label: 'Share', color: Colors.brown),
              // ),
              InkWell(
                onTap: () async {
                  final String? phone = leadDetails?.data?.contactNumber1;
                  final String? name = leadDetails?.data?.clientName;
                  final String? callMasterId = leadDetails?.data?.callMasterId;

                  if (phone == null || callMasterId == null) return;

                  String? baseUrl = await Common.getSharedPref("url");
                  baseUrl = baseUrl ?? "https://s2.login2.in";
                  if (baseUrl.contains('index.php')) {
                    baseUrl = baseUrl.replaceAll('index.php', '');
                    baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
                  }
                  List<int> bytes = utf8.encode(callMasterId);
                  String base64EncodedId = base64.encode(bytes);
                  String urlSafeBase64 = base64EncodedId
                      .replaceAll('+', '-')
                      .replaceAll('/', '_')
                      .replaceAll('=', '');

                  String fullUrl = "$baseUrl/redirect/lead/$urlSafeBase64";
                  String message = "Name: $name\nPhone: $phone\nLink: $fullUrl";
                  String encodedMessage = Uri.encodeComponent(message);
                  final whatsappLink = "https://wa.me/?text=$encodedMessage";

                  await launchUrl(Uri.parse(whatsappLink));
                },
                child: _buildActionColumn(
                    icon: Icons.share, label: 'Share', color: Colors.brown),
              ),
              //const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  if (contactPermission == 'true') {
                    saveContactDialog(context);
                  } else {
                    contactPermissionDialog(context);
                  }
                },
                child: _buildActionColumn(
                  icon: Icons.person_add,
                  label: 'Add',
                  color: Colors.blueAccent,
                ),
              ),

              // InkWell(
              //   onTap: () async {
              //     final String? phone = leadDetails?.data?.contactNumber1;
              //     final String? name = leadDetails?.data?.clientName;
              //     final String? callMasterId = leadDetails?.data?.callMasterId;

              //     if (phone == null || callMasterId == null) return;
              //     String? baseUrl = await Common.getSharedPref("url");
              //     baseUrl = baseUrl ?? "https://s2.login2.in";
              //     List<int> bytes = utf8.encode(callMasterId);
              //     String base64EncodedId = base64.encode(bytes);
              //     String urlSafeBase64 = base64EncodedId
              //         .replaceAll('+', '-')
              //         .replaceAll('/', '_')
              //         .replaceAll('=', '');
              //     String fullUrl = "$baseUrl/redirect/lead/$urlSafeBase64";
              //     String message = "Name: $name\nPhone: $phone\nLink: $fullUrl";
              //     String encodedMessage = Uri.encodeComponent(message);
              //     final whatsappLink = "https://wa.me/?text=$encodedMessage";
              //     await launchUrl(Uri.parse(whatsappLink));
              //   },
              //   child: _buildActionColumn(
              //       icon: Icons.share, label: 'Share', color: Colors.brown),
              // ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditLeadNew(
                            widget.token,
                            widget.callMasterId,
                            widget.editLead,
                            widget.deleteLead,
                            widget.cloudCall,
                            pageName: widget.pageName,
                            status: widget.status,
                            staff: widget.staff,
                            isCalled: widget.isCalled,
                            fromDate: widget.fromDate,
                            toDate: widget.toDate,
                            category: widget.category,
                          ),
                        ),
                      ).then((_) {
                        widget.onDataChanged();
                        Navigator.pop(context);
                      });
                      break;
                    case 'transfer':
                      if (transferPermission == "true") {
                        _showTransferDialog();
                      } else {
                        _showPermissionDialog('transfer permission');
                      }
                      break;
                    case 'add':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLeads(
                            widget.token,
                            page: 'leadDetails',
                            leadMasterId: leadDetails!.data!.callMasterId,
                            clientName: leadDetails!.data!.clientName,
                            phoneNumber: leadDetails!.data!.contactNumber1,
                            countryCode: leadDetails!.data!.countryCode,
                            fromDate: widget.fromDate,
                            toDate: widget.toDate,
                            editLead: widget.editLead,
                            deleteLead: widget.deleteLead,
                            cloudCall: widget.cloudCall,
                            address: leadDetails!.data!.address,
                          ),
                        ),
                      ).then((_) => widget.onDataChanged());
                      break;
                    case 'followup':
                      if (data.callResult != "Confirmed") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFollowup(
                              widget.token,
                              widget.editLead,
                              widget.deleteLead,
                              widget.cloudCall,
                              widget.callMasterId,
                              pageName: widget.pageName,
                              status: widget.status,
                              staff: widget.staff,
                              isCalled: widget.isCalled,
                              fromDate: widget.fromDate,
                              toDate: widget.toDate,
                              category: widget.category,
                              leadType: data.leadCategory ?? '',
                              leadTypeId: data.leadCategoryId ?? '',
                              leadSubType: data.leadSubCategory ?? '',
                              leadSubTypeId: data.leadSubCategoryId ?? '',
                              priority: data.priority ?? '',
                              priorityId: data.priorityId ?? '',
                              cost: data.cost ?? '',
                              address: data.address ?? '',
                              leadType1: widget.leadType,
                            ),
                          ),
                        ).then((_) {
                          widget.onDataChanged();
                          Navigator.pop(context);
                        });
                      } else {
                        Common.toastMessaage(
                          "You can't follow up on confirmed leads",
                          Colors.red,
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (widget.editLead)
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('Edit'),
                        dense: true,
                        horizontalTitleGap: 0,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'transfer',
                    child: ListTile(
                      leading: Icon(Icons.transfer_within_a_station, size: 20),
                      title: Text('Transfer'),
                      dense: true,
                      horizontalTitleGap: 0,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add',
                    child: ListTile(
                      leading: Icon(Icons.person_add_alt, size: 20),
                      title: Text('Add Leads'),
                      dense: true,
                      horizontalTitleGap: 0,
                    ),
                  ),
                  // const PopupMenuItem(
                  //   value: 'followup',
                  //   child: ListTile(
                  //     leading: Icon(Icons.add, size: 20),
                  //     title: Text('Followup'),
                  //     dense: true,
                  //     horizontalTitleGap: 0,
                  //   ),
                  // ),
                ],
                child: _buildActionColumn(
                  icon: Icons.more_vert,
                  label: 'More',
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? id) {
    switch (id) {
      case '1':
        return Colors.grey;
      case '2':
        return Colors.green;
      case '3':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _getSourceIcon(String? source) {
    IconData iconData;
    Color color = Colors.grey;

    switch (source) {
      case 'Direct Entry':
        iconData = FontAwesomeIcons.keyboard;
        color = Colors.blue;
        break;
      case 'Lead From Facebook':
        iconData = FontAwesomeIcons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'Lead From CSV':
        iconData = FontAwesomeIcons.fileCsv;
        color = Colors.green;
        break;
      case 'Lead From IVR':
        iconData = FontAwesomeIcons.phoneVolume;
        color = Colors.orange;
        break;
      case 'Lead from offical whatsapp':
        iconData = FontAwesomeIcons.whatsapp;
        color = const Color(0xFF25D366);
        break;
      default:
        iconData = Icons.source_rounded;
    }

    return Icon(iconData, size: 16, color: color);
  }

  Future<void> _refreshData(String newCallMasterId) async {
    Common.showProgressDialog(context, "Loading...");
    try {
      final response =
          await HttpService.leadDetails(widget.token, newCallMasterId);
      if (response != null) {
        setState(() {
          callMasterId = newCallMasterId;
          leadDetails = response;

          final data = leadDetails!.data!;
          contactFName.text = data.clientName ?? '';
          contactMobile.text = data.contactNumber1 ?? '';
          address.text = data.address ?? '';
          cost.text = data.cost ?? '';
          leadTypeId = data.leadCategoryId ?? '';
          leadType = data.leadCategory ?? 'Lead Category';
          leadSubTypeId = data.leadSubCategoryId ?? '';
          leadSubType = data.leadSubCategory ?? 'Lead Sub Category';
          priorityId = data.priorityId ?? '2';
          priority = data.priority ?? 'Normal';
        });

        await Future.wait<dynamic>([
          _fetchActivitiesAndCallHistory(),
          _fetchRenewalDetails(),
          _fetchCallResultReason(),
          _fetchLeadSubType(),
          _fetchAdditionalData(newCallMasterId),
          listFolderList(widget.token, newCallMasterId, ''),
        ]);
      }
    } catch (e) {
      log("Error refreshing lead details: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _fetchAdditionalData(String cmId) async {
    try {
      final addonResponse = await HttpService.listAddonDet(widget.token, cmId);
      final folderResponse =
          await HttpService.listFolderAndFiles(widget.token, cmId, '');
      final milestoneResponse =
          await HttpService.leadMileStone(widget.token, cmId);
      final followupResponse =
          await HttpService.leadFollowupData(widget.token, cmId);

      setState(() {
        leadDetailsAdditional = addonResponse;
        listFolder = folderResponse;
        mileStone = milestoneResponse;
        leadDetailsFollowup = followupResponse;
      });
    } catch (e) {
      log("Error fetching additional lead data: $e");
    }
  }

  Widget _buildActionColumn({
    IconData? icon,
    String? imageAsset,
    required String label,
    required Color color,
    bool isSolid = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSolid ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: imageAsset != null
              ? Image.asset(
                  imageAsset,
                  width: 20,
                  height: 20,
                  color: isSolid ? Colors.white : color,
                )
              : Icon(icon, color: isSolid ? Colors.white : color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> postFollowup() async {
    if (callResultId.isEmpty) {
      Common.toastMessaage('Select Status', Colors.red);
      return;
    }
    if (callResponseId.isEmpty) {
      Common.toastMessaage('Select Call Result', Colors.red);
      return;
    }

    bool isFollowup =
        leadSettings?.isFollowupRequiredBool ?? (callResultId == '2');
    if (isFollowup && nextFollowupDate1.text.isEmpty) {
      Common.toastMessaage('Select Next Followup Date', Colors.red);
      return;
    }

    bool isReasonReq = leadSettings?.isReasonRequiredBool ?? false;
    if (isReasonReq && callResultReasonId.isEmpty) {
      Common.toastMessaage('Select Reason', Colors.red);
      return;
    }

    if (createOrder == true && products.isEmpty) {
      Common.toastMessaage('Choose at least one product', Colors.red);
    } else if (createOrder == true && staffId == "") {
      Common.toastMessaage(
          'Collected Staff is required to add invoice', Colors.red);
    } else if (createRenewal == true &&
        commonDetails!.data.isRenewal &&
        startDate.text == "") {
      Common.toastMessaage('Start date is required to add renewal', Colors.red);
    } else if (createRenewal == true &&
        commonDetails!.data.isRenewal &&
        endDate.text == "") {
      Common.toastMessaage('End date is required to add renewal', Colors.red);
    } else {
      setState(() {
        isSavingFollowup = true;
      });

      Common.showProgressDialog(context, "Saving Followup...");

      try {
        String productIds = _selectedProducts.map((p) => p.id).join(',');

        final result = await HttpService.addLeadsFollowupUpdated(
            widget.token,
            callResultId,
            nextFollowupDate1.text,
            cost.text,
            address.text,
            leadTypeId,
            leadSubTypeId,
            remarks.text,
            widget.callMasterId,
            calledDate1.text,
            '', // callHistoryId
            priorityId,
            checked,
            timeBefore.text,
            callResponseId,
            callResultReasonId,
            createOrder,
            createRenewal ? "renewal" : "invoice",
            detailsResponse?.data.checkId ?? '',
            invoiceDate,
            products,
            reminderTemplate.text,
            allTotal,
            startDate.text,
            endDate.text,
            paymentStatus,
            subTotal,
            totalTaxAmount,
            discount.text,
            shippingCharge.text,
            paymentMethod,
            paidAmount.text,
            staffId,
            isDifrent,
            renProducts,
            targetGroups,
            products: productIds,
            createCustomer: createCustomer,
            whatsappLead: whatsappLead.text,
            emailLead: emailLead.text);

        if (context.mounted) {
          Navigator.pop(context); // Close progress dialog

          if (result.status == true) {
            Common.toastMessaage(result.message, Colors.green);
            widget.onDataChanged();
            Navigator.pop(context); // Close popup
          } else {
            Common.toastMessaage(result.message, Colors.red);
          }
        }
      } catch (e) {
        log("Error saving followup: $e");
        if (context.mounted) {
          Navigator.pop(context); // Close progress dialog
          Common.toastMessaage("Error saving followup: $e", Colors.red);
        }
      } finally {
        if (mounted) {
          setState(() {
            isSavingFollowup = false;
          });
        }
      }
    }
  }

  Widget _buildFollowupTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (isCreatingOrderOnly)
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Order/Invoice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2a86c9),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              isCreatingOrderOnly = false;
                              createOrder = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildOrderSection(),
                    if (commonDetails?.data.isRenewal == true) ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Create Renewal',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        value: createRenewal,
                        onChanged: (value) {
                          setState(() {
                            createRenewal = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF2a86c9),
                      ),
                      if (createRenewal) _buildRenewalSection(),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSavingFollowup ? null : _postOnlyOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isSavingFollowup
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Order',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Add New Followup Form - Restricted for closed leads (Status ID '4' or name 'Closed')
            if (leadDetails?.data?.callResultId != "4" &&
                leadDetails?.data?.callResult != "Closed")
              _buildAddNewFollowupForm()
            else
              const Card(
                margin: EdgeInsets.all(12),
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This lead is Closed. Further followups are restricted.',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          // List of existing followups
          leadDetailsFollowup == null ||
                  leadDetailsFollowup!.data.followUpData.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No followups found'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: leadDetailsFollowup!.data.followUpData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final followup =
                        leadDetailsFollowup!.data.followUpData[index];
                    final fNo =
                        leadDetailsFollowup!.data.followUpData.length - index;
                    return _buildFollowupItem(followup, fNo);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAddNewFollowupForm() {
    if (commonDetails == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            setState(() {
              calledDate1.text =
                  DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
            });
          }
        },
        title: const Text(
          'Add New Followup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2a86c9),
          ),
        ),
        subtitle: const Text('Tap to expand and add a new followup'),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.blue.shade50,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Dropdown
                _buildDropdown(
                  label: 'Stages *',
                  value: callResultId.isEmpty ? null : callResultId,
                  items: commonDetails!.data.callResult.map((item) {
                    return DropdownMenuItem(
                      value: item.callResultId.toString(),
                      child: Text(item.callResult),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      callResultId = value!;
                      callResult = commonDetails!.data.callResult
                          .firstWhere((element) =>
                              element.callResultId.toString() == value)
                          .callResult;
                      _fetchCallResultReason();
                      _fetchLeadExtraSettings(callResultId).then((_) {
                        if (leadSettings != null &&
                            !leadSettings!.isFollowupRequiredBool) {
                          if (mounted) {
                            setState(() {
                              nextFollowupDate1.clear();
                              checked = false;
                            });
                          }
                        } else if (leadSettings == null &&
                            callResultId != '2') {
                          if (mounted) {
                            setState(() {
                              nextFollowupDate1.clear();
                              checked = false;
                            });
                          }
                        }
                      });
                    });
                  },
                ),

                // Next Followup Date (Conditional)
                if (leadSettings != null
                    ? leadSettings!.isFollowupRequiredBool
                    : callResultId == '2') // Assuming '2' is Pending/Followup
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Followup Date *',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          DateTime now = DateTime.now();
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final dt = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute);

                              if (!dt.isAfter(now)) {
                                if (context.mounted) {
                                  Common.toastMessaage(
                                      'You cannot choose a past time for the follow-up date',
                                      Colors.red);
                                }
                                return;
                              }

                              setState(() {
                                nextFollowupDate1.text =
                                    DateFormat('dd-MM-yyyy HH:mm').format(dt);
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                nextFollowupDate1.text.isEmpty
                                    ? 'Select Date & Time'
                                    : nextFollowupDate1.text,
                              ),
                              const Icon(Icons.calendar_month, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Reminder
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reminder',
                            style: TextStyle(fontSize: 14)),
                        value: checked,
                        onChanged: (value) {
                          setState(() {
                            checked = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (checked) ...[
                        Row(
                          children: [
                            const Text('Time Before (min): ',
                                style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: timeBefore,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          int val =
                                              int.tryParse(timeBefore.text) ??
                                                  0;
                                          setState(() =>
                                              timeBefore.text = "${val + 1}");
                                        },
                                        child: const Icon(Icons.arrow_drop_up,
                                            size: 18),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          int val =
                                              int.tryParse(timeBefore.text) ??
                                                  0;
                                          if (val > 0) {
                                            setState(() =>
                                                timeBefore.text = "${val - 1}");
                                          }
                                        },
                                        child: const Icon(Icons.arrow_drop_down,
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),

                // Call Result Description Dropdown
                _buildDropdown(
                  label: 'Call Result *',
                  value: callResponseId.isEmpty ? null : callResponseId,
                  items: commonDetails!.data.callResponseStatus.map((item) {
                    return DropdownMenuItem(
                      value: item.callResponseId.toString(),
                      child: Text(item.callResponse),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      callResponseId = value!;
                      callResponse = commonDetails!.data.callResponseStatus
                          .firstWhere((element) =>
                              element.callResponseId.toString() == value)
                          .callResponse;
                    });
                  },
                ),

                // Call Result Reason (if available)
                if (callResultReason != null &&
                    (callResultReason!.data?.isNotEmpty ?? false))
                  _buildDropdown(
                    label: (leadSettings?.isReasonRequiredBool ?? false)
                        ? 'Reason *'
                        : 'Reason',
                    value:
                        callResultReasonId.isEmpty ? null : callResultReasonId,
                    items: callResultReason!.data!.map((item) {
                      return DropdownMenuItem(
                        value: item.id ?? '',
                        child: Text(item.reason ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        callResultReasonId = value!;
                      });
                    },
                  ),

                // Called Date
                const Text(
                  'Called Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          final dt = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute);
                          calledDate1.text =
                              DateFormat('dd-MM-yyyy HH:mm').format(dt);
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(calledDate1.text),
                        const Icon(Icons.access_time_filled, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // More Details Toggle
                InkWell(
                  onTap: () {
                    setState(() {
                      isMoreDetails = !isMoreDetails;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isMoreDetails ? 'Less Details' : 'More Details',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          isMoreDetails
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),
                ),

                Visibility(
                  visible: isMoreDetails,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: commonDetails!.data.priority.length,
                          itemBuilder: (context, i) {
                            final p = commonDetails!.data.priority[i];
                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Radio<String>(
                                      activeColor: p.priorityId.toString() ==
                                              '1'
                                          ? Colors.grey
                                          : p.priorityId.toString() == '2'
                                              ? Colors.green
                                              : p.priorityId.toString() == '3'
                                                  ? Colors.red
                                                  : Colors.purple,
                                      value: p.priorityId.toString(),
                                      groupValue: priorityId,
                                      onChanged: (String? value) {
                                        setState(() {
                                          priorityId = value!;
                                          priority = p.priority;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(p.priority,
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category and Subcategory
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Category',
                              value: leadTypeId.isEmpty ? null : leadTypeId,
                              items:
                                  commonDetails!.data.leadCategory.map((item) {
                                return DropdownMenuItem(
                                  value: item.leadCategoryId.toString(),
                                  child: Text(item.leadCategory),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  leadTypeId = value!;
                                  leadType = commonDetails!.data.leadCategory
                                      .firstWhere((element) =>
                                          element.leadCategoryId.toString() ==
                                          value)
                                      .leadCategory;
                                  _fetchLeadSubType();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Sub Category',
                              value:
                                  leadSubTypeId.isEmpty ? null : leadSubTypeId,
                              items: (leadSubTypeList?.data ?? []).map((item) {
                                return DropdownMenuItem(
                                  value: item.leadSubCategoryId.toString(),
                                  child: Text(item.leadSubCategory ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  leadSubTypeId = value!;
                                  leadSubType = leadSubTypeList!.data!
                                      .firstWhere((element) =>
                                          element.leadSubCategoryId
                                              .toString() ==
                                          value)
                                      .leadSubCategory!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      // WhatsApp Number and Email ID
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WhatsApp Number',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: whatsappLead,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'WhatsApp Number',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(12),
                                    prefixIcon: const Icon(
                                        FontAwesomeIcons.whatsapp,
                                        size: 18,
                                        color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email ID',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: emailLead,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email ID',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(12),
                                    prefixIcon: const Icon(Icons.email,
                                        size: 18, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Product Selection (Moved from More Details)
                      const Text(
                        'Products',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _productSearchCtrl,
                        onChanged: _onFollowupProductSearch,
                        decoration: InputDecoration(
                          hintText: 'Search Product...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      if (_productSearchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _productSearchResults.length,
                            itemBuilder: (ctx, i) {
                              final p = _productSearchResults[i];
                              return ListTile(
                                title: Text(p.productName ?? ''),
                                subtitle: Text("₹ ${p.totalAmount}"),
                                onTap: () => _addFollowupProduct(p),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _selectedProducts
                            .map((p) => Chip(
                                  label: Text(p.productName ?? ''),
                                  onDeleted: () => _removeFollowupProduct(p),
                                  backgroundColor: Colors.blue.shade50,
                                  deleteIconColor: Colors.red,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cost,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cost',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon:
                                    Icon(Icons.currency_rupee, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: address,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.home, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Common Response suggestions
                      if (commonDetails!.data.callResponse.isNotEmpty)
                        SizedBox(
                          height: 35,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: commonDetails!.data.callResponse.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      remarks.text = commonDetails!
                                          .data.callResponse[i]
                                          .toString();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        commonDetails!.data.callResponse[i]
                                            .toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Remarks
                      TextField(
                        controller: remarks,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Create Order and Create Customer Checkboxes
                if ((leadSettings != null
                        ? leadSettings!.createInvoiceBool
                        : (callResultId == '4' &&
                            commonDetails!.data.customerAddInvoicePermission ==
                                true)) ||
                    (leadSettings?.createCustomerBool ?? false))
                  Row(
                    children: [
                      if (leadSettings != null
                          ? leadSettings!.createInvoiceBool
                          : (callResultId == '4' &&
                              commonDetails!
                                      .data.customerAddInvoicePermission ==
                                  true))
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Create Order',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            value: createOrder,
                            onChanged: (value) {
                              setState(() {
                                createOrder = value!;
                                if (!createOrder) createRenewal = false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xFF2a86c9),
                          ),
                        ),
                      if (leadSettings?.createCustomerBool ?? false)
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Create Customer',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            value: createCustomer,
                            onChanged: (value) {
                              setState(() {
                                createCustomer = value!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xFF2a86c9),
                          ),
                        ),
                    ],
                  ),

                // Order Details (Conditional)
                if (createOrder &&
                    (leadSettings != null
                        ? leadSettings!.createInvoiceBool
                        : (callResultId == '4' &&
                            commonDetails!.data.customerAddInvoicePermission ==
                                true)))
                  _buildOrderSection(),

                // Create Renewal Checkbox (Conditional)
                if (createOrder &&
                    (leadSettings != null
                        ? leadSettings!.createRenewalBool
                        : (callResultId == '4' &&
                            commonDetails!.data.isRenewal == true)))
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Create Renewal',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: createRenewal,
                    onChanged: (value) {
                      setState(() {
                        createRenewal = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF2a86c9),
                  ),

                // Renewal Details (Conditional)
                if (createRenewal &&
                    createOrder &&
                    (leadSettings != null
                        ? leadSettings!.createRenewalBool
                        : commonDetails!.data.isRenewal == true))
                  _buildRenewalSection(),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSavingFollowup
                        ? null
                        : () {
                            if (callResultId == '4' && createOrder == false) {
                              createOrderDialog(context);
                            } else {
                              postFollowup();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a86c9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: isSavingFollowup
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Followup',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postOnlyOrder() async {
    if (creatingOrderFollowupId == null) return;

    if (createOrder && products.isEmpty) {
      Common.toastMessaage('Please add at least one product', Colors.red);
      return;
    }

    if (paymentStatus == null) {
      Common.toastMessaage('Please select payment status', Colors.red);
      return;
    }

    if (paymentStatus != 'unpaid' && paymentMethod == null) {
      Common.toastMessaage('Please select payment method', Colors.red);
      return;
    }

    if (staffId.isEmpty) {
      Common.toastMessaage('Please select account head', Colors.red);
      return;
    }

    setState(() => isSavingFollowup = true);

    try {
      final response = await HttpService.postConfirmedFollowup(
        creatingOrderFollowupId!,
        remarks.text, // Reusing remarks as invoice remarks
        renewalRemarks.text,
        createRenewal ? "renewal" : "invoice",
        detailsResponse!.data.checkId,
        invoiceDate,
        products,
        reminderTemplate.text,
        allTotal,
        startDate.text,
        endDate.text,
        paymentStatus,
        subTotal,
        totalTaxAmount,
        discount.text,
        shippingCharge.text,
        paymentMethod,
        paidAmount.text,
        staffId,
        isDifrent,
        renProducts,
        targetGroups,
      );

      if (response != null && response.status == true) {
        Common.toastMessaage(response.message, Colors.green);
        setState(() {
          isCreatingOrderOnly = false;
          createOrder = false;
          createRenewal = false;
          products.clear();
          renProducts.clear();
          _recalculateTotals();
        });
        await _refreshData(widget.callMasterId);
        widget.onDataChanged();
      } else {
        Common.toastMessaage(
            response?.message ?? 'Failed to create order', Colors.red);
      }
    } catch (e) {
      log('Error posting order: $e');
      Common.toastMessaage('Error posting order', Colors.red);
    } finally {
      if (mounted) setState(() => isSavingFollowup = false);
    }
  }

  Widget _buildOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Invoice Number:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Invoice Date:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(
              width: 150,
              child: DateTimePicker(
                type: DateTimePickerType.date,
                initialValue: invoiceDate.toString(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onChanged: (val) {
                  setState(() {
                    invoiceDate = DateTime.parse(val);
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => addProductsDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Product Table
        if (products.isNotEmpty) _buildProductTable(),

        const SizedBox(height: 16),

        // Totals
        _buildTotalRow('Sub Total', subTotal.toStringAsFixed(2)),
        _buildTotalRow('Tax Amount', totalTaxAmount.toStringAsFixed(2)),
        _buildTotalRow('Discount', null, controller: discount,
            onChanged: (val) {
          _recalculateTotals();
        }),
        _buildTotalRow('Shipping Charge', null, controller: shippingCharge,
            onChanged: (val) {
          _recalculateTotals();
        }),
        const Divider(),
        _buildTotalRow('Grand Total', allTotal.toStringAsFixed(2),
            isGrandTotal: true),

        const SizedBox(height: 16),

        // Payment Details
        _buildDropdown(
          label: 'Payment Status *',
          value: paymentStatus,
          items: [
            const DropdownMenuItem(value: 'paid', child: Text('Paid')),
            const DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
            const DropdownMenuItem(value: 'partial', child: Text('Partial')),
          ],
          onChanged: (val) {
            setState(() {
              paymentStatus = val;
              if (paymentStatus == 'paid') {
                paidAmount.text = allTotal.toStringAsFixed(2);
              } else if (paymentStatus == 'unpaid') {
                paidAmount.text = '0.00';
              }
            });
          },
        ),

        if (paymentStatus != 'unpaid')
          Column(
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: paidAmount,
                keyboardType: TextInputType.number,
                readOnly: paymentStatus == 'paid',
                decoration: const InputDecoration(
                  labelText: 'Paid Amount *',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Payment Method *',
                value: paymentMethod,
                items: detailsResponse?.data.paymentMethods.map((m) {
                      return DropdownMenuItem(
                        value: m.id.toString(),
                        child: Text(m.name),
                      );
                    }).toList() ??
                    [],
                onChanged: (val) {
                  setState(() {
                    paymentMethod = val;
                  });
                },
              ),
            ],
          ),

        const SizedBox(height: 12),
        const Text('Account Head *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => collectedStaffDialog(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(staffName),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        const Text('Target Group',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => targetGroupDialog(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    targetGroupNames.isEmpty
                        ? 'Select Target Groups'
                        : targetGroupNames.join(', '),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRenewalSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date *',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                          if (typeDuration.isNotEmpty) {
                            final end = picked
                                .add(Duration(days: int.parse(typeDuration)));
                            endDate.text = DateFormat('dd-MM-yyyy').format(end);
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(startDate.text.isEmpty
                              ? 'Start Date'
                              : startDate.text),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End Date *',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              endDate.text.isEmpty ? 'End Date' : endDate.text),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        TextFormField(
          onTap: () {
            dropDialog(context);
          },
          readOnly: true,
          controller: reminderTemplate,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              labelText: 'Remind Template ',
              prefixIcon: Icon(Icons.notifications, color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              labelStyle: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(
          height: 14,
        ),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Is renewal amount is diffrent?'),
            value: isDifrent, // initial value of the checkbox
            onChanged: (bool? value) {
              setState(() {
                isDifrent = value!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading),
        const SizedBox(
          height: 14,
        ),
        Visibility(
          visible: isDifrent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(1),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.2), // Using 10%
                    1: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.16), // Using 30%
                    2: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.10),
                    3: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.16), // Using 20%
                    4: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.20),
                    5: FixedColumnWidth(
                        MediaQuery.of(context).size.width * 0.10),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: const Color(0xFFece9fd),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Product',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Rate',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Qty',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tax',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Amount',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(' ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              renProducts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No Products !",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: renProducts.length,
                        itemBuilder: (context, index) {
                          Color color = index % 2 == 0
                              ? const Color(0xFFF3F3F3)
                              : const Color(0xFFece9fd);
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Table(
                              columnWidths: {
                                0: FixedColumnWidth(
                                    MediaQuery.of(context).size.width *
                                        0.2), // Using 10%
                                1: FixedColumnWidth(
                                    MediaQuery.of(context).size.width *
                                        0.16), // Using 30%
                                2: FixedColumnWidth(
                                    MediaQuery.of(context).size.width * 0.10),
                                3: FixedColumnWidth(
                                    MediaQuery.of(context).size.width *
                                        0.16), // Using 20%
                                4: FixedColumnWidth(
                                    MediaQuery.of(context).size.width * 0.20),
                                5: FixedColumnWidth(
                                    MediaQuery.of(context).size.width * 0.10),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1),
                                    color: color,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        renProducts[index]['product_name'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        renProducts[index]['product_rate'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        renProducts[index]['quantity'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        String.fromCharCodes(renProducts[index]
                                                ['total_tax_amount']
                                            .runes),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        renProducts[index]['total_amount'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        changeAmount(
                                                context,
                                                renProducts[index]
                                                    ['product_name'],
                                                renProducts[index]
                                                    ['product_rate'],
                                                renProducts[index]['quantity'],
                                                renProducts[index]
                                                    ['total_tax_amount'],
                                                renProducts[index]
                                                    ['tax_percent'],
                                                renProducts[index]
                                                    ['total_amount'],
                                                renProducts[index]
                                                    ['product_id'],
                                                renProducts[index]
                                                        ['description'] ??
                                                    "nil",
                                                index)
                                            .then((_) {
                                          setState(() {});
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _onFollowupProductSearch(String v) {
    if (v.isEmpty) {
      setState(() => _productSearchResults = []);
      return;
    }
    setState(() {
      _productSearchResults = productSectionModel?.data
              ?.where((p) =>
                  (p.productName ?? '').toLowerCase().contains(v.toLowerCase()))
              .toList() ??
          [];
    });
  }

  void _addFollowupProduct(LeadProduct p) {
    setState(() {
      if (!_selectedProducts.any((item) => item.id == p.id)) {
        _selectedProducts.add(p);
      }
      _productSearchCtrl.clear();
      _productSearchResults = [];
      _updateFollowupCostFromProducts();
    });
  }

  void _removeFollowupProduct(LeadProduct p) {
    setState(() {
      _selectedProducts.removeWhere((item) => item.id == p.id);
      _updateFollowupCostFromProducts();
    });
  }

  void _updateFollowupCostFromProducts() {
    double total = 0;
    for (var p in _selectedProducts) {
      total += double.tryParse(p.totalAmount ?? '0') ?? 0;
    }
    cost.text = total.toStringAsFixed(2);
  }

  Widget _buildProductTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Product',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 40),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                dense: true,
                title: Text(p['product_name'],
                    style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                    'Rate: ₹${p['product_rate']} + Tax: ₹${p['total_tax_amount']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('x${p['quantity']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text('₹${p['total_amount']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          _removeProduct(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String? value,
      {TextEditingController? controller,
      ValueChanged<String>? onChanged,
      bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
                  fontSize: isGrandTotal ? 16 : 14)),
          if (controller != null)
            SizedBox(
              width: 100,
              height: 35,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(),
                ),
                onChanged: onChanged,
              ),
            )
          else
            Text('₹ $value',
                style: TextStyle(
                    fontWeight:
                        isGrandTotal ? FontWeight.bold : FontWeight.bold,
                    fontSize: isGrandTotal ? 16 : 14,
                    color:
                        isGrandTotal ? const Color(0xFF2a86c9) : Colors.black)),
        ],
      ),
    );
  }

  void _recalculateTotals() {
    double d = double.tryParse(discount.text) ?? 0.0;
    double s = double.tryParse(shippingCharge.text) ?? 0.0;

    setState(() {
      allTotal = subTotalGrand + s - d;
      if (paymentStatus == 'paid') {
        paidAmount.text = allTotal.toStringAsFixed(2);
      }
    });
  }

  void _removeProduct(int index) {
    subTotalGrand -= double.parse(products[index]['total_amount']);
    subTotal -= (double.parse(products[index]['product_rate']) *
        double.parse(products[index]['quantity']));
    totalTaxAmount -= double.parse(products[index]['total_tax_amount']);

    products.removeAt(index);
    if (renProducts.length > index) renProducts.removeAt(index);

    if (products.isEmpty) {
      discount.clear();
      shippingCharge.clear();
      subTotal = 0.00;
      subTotalGrand = 0.00;
      totalTaxAmount = 0.00;
      allTotal = 0.00;
      paidAmount.text = '0.00';
    } else {
      _recalculateTotals();
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // 1. Ensure unique items to avoid duplicate value crash
    final seenValues = <String?>{};
    final uniqueItems =
        items.where((item) => seenValues.add(item.value)).toList();

    // 2. Check if the value exists in the unique items list. If not, set to null to avoid crash.
    String? safeValue =
        uniqueItems.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: safeValue,
              items: uniqueItems,
              onChanged: onChanged,
              hint: Text('Select $label'),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFollowupItem(af.FollowUpDatum followup, int followupNumber) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 20,
          child: Container(
            width: 1.0,
            color: Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 12, bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  image: followup.proPicThumb.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(followup.proPicThumb),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: followup.proPicThumb.isEmpty
                    ? const Icon(Icons.person, size: 18, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            followup.staffName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Action Icons Section - Hidden if lead is Closed (ID '4' or 'Closed')
                        if (leadDetailsAdditional!.data.createCustomerInvoice ==
                                true &&
                            leadDetailsFollowup!
                                    .data.followUpData[0].callResult ==
                                "Confirmed" &&
                            leadDetailsAdditional!.data.isCreateOrder == true)
                          InkWell(
                            onTap: () {
                              setState(() {
                                isCreatingOrderOnly = true;
                                createOrder = true;
                                creatingOrderFollowupId = widget.callMasterId;
                                // We also need to fetch renewal details if not already fetched
                                _fetchRenewalDetails();
                              });
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.green,
                              size: 22,
                            ),
                          )
                        else if (leadDetails?.data?.callResultId != "4" &&
                            leadDetails?.data?.callResult != "Closed" &&
                            leadDetailsFollowup!
                                    .data.followUpData[0].callResult ==
                                "Confirmed")
                          InkWell(
                            onTap: () {
                              Get.to(() => CustomerDashboard(
                                    token: widget.token,
                                    name: name ?? '',
                                    userId: userId ?? '',
                                    phoneCallLogPermission:
                                        phoneCallLogPermission,
                                    custId: leadDetailsAdditional!
                                        .data.customerId
                                        .toString(),
                                  ))?.then((r) {
                                _refreshData(widget.callMasterId);
                                widget.onDataChanged();
                              });
                            },
                            child: const Icon(
                              Icons.menu,
                              color: Colors.green,
                              size: 22,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (followup.isEdit == true)
                          InkWell(
                            onTap: () {
                              Get.to(() => EditFollowup(
                                    widget.token,
                                    widget.editLead,
                                    widget.deleteLead,
                                    widget.cloudCall,
                                    widget.callMasterId,
                                    followup.callDetailsId.toString(),
                                    pageName: widget.pageName,
                                    status: widget.status,
                                    staff: widget.staff,
                                    isCalled: widget.isCalled,
                                    fromDate: widget.fromDate,
                                    toDate: widget.toDate,
                                    category: widget.category,
                                  ))?.then((r) {
                                _refreshData(widget.callMasterId);
                                widget.onDataChanged();
                              });
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 18,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (followup.isDelete == true)
                          InkWell(
                            onTap: () {
                              _deleteDialog(context, followup.callDetailsId);
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(followup.callResultId),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            followup.callResult,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      followup.remarks,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (followup.reason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Reason: ${followup.reason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (followup.productNames.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Products: ${followup.productNames}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              followup.scheduledDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "F.No : $followupNumber",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _deleteDialog(BuildContext context, String followupId) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _deleteFollowup(context, followupId);
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  Future<void> _deleteFollowup(BuildContext context, String followupId) async {
    Common.showProgressDialog(context, "Deleting..");
    DeleteLeadFollowModel delete = await HttpService.deleteLeadFollowup(
        widget.token, followupId, widget.callMasterId);
    if (delete.data == true) {
      Common.toastMessaage(delete.message, Colors.green);
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        _refreshData(widget.callMasterId);
        widget.onDataChanged();
      }
    } else {
      Common.toastMessaage(delete.message, Colors.red);
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
      }
    }
  }

  Widget _buildActivitiesTab() {
    if (isActivityLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (activeMode == null || activeMode!.activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No activities found'),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: activeMode!.activities.length,
      itemBuilder: (context, index) {
        final activity = activeMode!.activities[index];
        return Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 32,
              child: Container(
                width: 1.0,
                color: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      image: activity.proPicThumb.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(activity.proPicThumb),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: activity.proPicThumb.isEmpty
                        ? const Icon(Icons.person, size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.staffName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.remark,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              activity.createdTime,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCallHistoryTab() {
    if (isCallHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (callDetailsDataS == null ||
        callDetailsDataS!.data == null ||
        callDetailsDataS!.data!.callHistory!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No call history found'),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: callDetailsDataS!.data!.callHistory!.length,
      itemBuilder: (context, index) {
        final call = callDetailsDataS!.data!.callHistory![index];
        return _buildCallHistoryItem(call);
      },
    );
  }

  Widget _buildCallHistoryItem(CallHistoryData call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.direction,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  call.time,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  call.date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                call.callDurationHr,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: call.status.toLowerCase() == "attended"
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  call.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: call.status.toLowerCase() == "attended"
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final data = leadDetails!.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailSection('Basic Information', [
            _buildDetailRow('Client Name', data.clientName ?? '-'),
            _buildDetailRow('Phone', data.contactNumber1 ?? '-'),
            _buildDetailRow('WhatsApp (Full)', data.whatsaAppNumber ?? '-'),
            _buildDetailRow(
                'WhatsApp (No Code)', _stripCountryCode(data.whatsaAppNumber)),
            _buildDetailRow(
                'WA Country Code', data.whatsappNumberCountryCode ?? '-'),
            _buildDetailRow('Email', data.emailId ?? '-'),
            _buildDetailRow('Assigned to', data.staffName ?? '-'),
            _buildDetailRow('Created date', data.createdDate ?? '-'),
            _buildDetailRow('Call Result', data.callResult ?? '-'),
            _buildDetailRow('Cost', data.cost ?? '-'),
            _buildDetailRow('Source', data.leadSource ?? '-'),
            _buildDetailRow('Remark', data.remarks ?? '-'),
          ]),
          const SizedBox(height: 16),
          if (_selectedProducts.isNotEmpty) ...[
            _buildDetailSection(
                'Selected Products',
                _selectedProducts
                    .map((p) => _buildDetailRow(p.productName ?? 'Product',
                        '₹ ${p.totalAmount ?? '0'}'))
                    .toList()),
            const SizedBox(height: 16),
          ],
          _buildDetailSection('Location Information', [
            _buildDetailRow('State', data.stateName ?? '-'),
            _buildDetailRow('District', data.districtName ?? '-'),
            _buildDetailRow('PIN Code', data.pinCode ?? '-'),
            _buildDetailRow('Post Office', data.postOffice ?? '-'),
          ]),
          if (leadDetailsAdditional?.data.additionalFields.isNotEmpty ??
              false) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
                'Additional Fields',
                leadDetailsAdditional!.data.additionalFields
                    .map((field) => _buildDetailRow(field.name, field.value))
                    .toList()),
          ],
        ],
      ),
    );
  }

  String _stripCountryCode(String? whatsapp) {
    if (whatsapp == null || whatsapp.isEmpty) return '-';
    if (whatsapp.startsWith('91') && whatsapp.length > 10) {
      return whatsapp.substring(2);
    }
    return whatsapp;
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2a86c9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dialogue(BuildContext context, title) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: const Text(
              'You have no permission to access the feature please contact the support team'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    if (listFolder == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (listPath.isNotEmpty)
                InkWell(
                  onTap: () {
                    setState(() {
                      bool checkString = backPath.contains('/');
                      if (checkString) {
                        backPath =
                            backPath.substring(0, backPath.lastIndexOf('/'));
                        path = '$backPath/';
                      } else {
                        backPath = '';
                        path = '';
                      }
                      listPath = backPath;
                      folderActionEnable = false;
                      selectedRawIndex = '';
                      listFolderList(widget.token, callMasterId, backPath);
                    });
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(5),
                    dashPattern: const [8, 4],
                    strokeCap: StrokeCap.round,
                    color: Colors.black,
                    child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios,
                              color: Colors.black, size: 12),
                          SizedBox(width: 8),
                          Text('Back', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (fileManagerPermission?.data?.createFile == true) {
                        _showCreateFolderDialog();
                      } else {
                        _dialogue(context, 'Create Folder');
                      }
                    },
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      dashPattern: const [8, 4],
                      strokeCap: StrokeCap.round,
                      color: const Color(0xFF2a86c9),
                      child: Container(
                        width: 110,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded,
                                color: Color(0xFF2a86c9), size: 16),
                            SizedBox(width: 8),
                            Text('New Folder',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF2a86c9))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (folderActionEnable) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        if (fileManagerPermission?.data?.renameFile == true) {
                          _showRenameFolderDialog();
                        } else {
                          _dialogue(context, 'Rename Folder');
                        }
                      },
                      child: const Icon(Icons.edit,
                          color: Color(0xFF2a86c9), size: 20),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        if (fileManagerPermission?.data?.deleteFile == true) {
                          _showDeleteConfirmDialog();
                        } else {
                          _dialogue(context, 'Delete Folder');
                        }
                      },
                      child: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: listFolder!.data!.isEmpty
              ? const Center(child: Text('No documents found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: listFolder!.data!.length,
                  itemBuilder: (context, index) {
                    final item = listFolder!.data![index];
                    bool isSelected = selectedRawIndex == index.toString();

                    return InkWell(
                      onLongPress: () {
                        setState(() {
                          deletePath = '${item.path}';
                          folderActionEnable = true;
                          rawId = item.id.toString();
                          selectedRawIndex = index.toString();
                          editableName = item.name.toString();
                          fileNameEdit.text = editableName;
                        });
                      },
                      onTap: () {
                        if (fileManagerPermission?.data?.openFile == true) {
                          setState(() {
                            folderActionEnable = false;
                            rawId = '';
                            selectedRawIndex = '';
                            if (item.isFolder == 'Y') {
                              backPath = '${item.path}';
                              path = '${item.path}/';
                              listPath = '${item.path}';
                              listFolderList(
                                  widget.token, callMasterId, listPath);
                            } else {
                              _viewDocument(item);
                            }
                          });
                        } else {
                          _dialogue(context, 'Open Folder');
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2a86c9)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _getFileIcon(item),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                item.name ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF2a86c9)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateFolderDialog() {
    showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('New Folder',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: folderName,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Folder Name",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (folderName.text.isEmpty) {
                                Common.toastMessaage(
                                    'Enter Folder name', Colors.red);
                              } else {
                                final res = await HttpService.createFolder(
                                    widget.token,
                                    callMasterId,
                                    '$path${folderName.text}');
                                if (res.data == true) {
                                  listFolderList(
                                      widget.token, callMasterId, listPath);
                                  folderName.text = '';
                                  if (mounted) Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('Create',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  void _showRenameFolderDialog() {
    showGeneralDialog(
      barrierLabel: "showRenameDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rename Folder',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: fileNameEdit,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Folder Name",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (fileNameEdit.text.isEmpty) {
                                Common.toastMessaage(
                                    'Enter Folder name', Colors.red);
                              } else {
                                final res = await HttpService.renameFolder(
                                  widget.token,
                                  callMasterId,
                                  listPath,
                                  editableName,
                                  fileNameEdit.text,
                                  rawId,
                                );
                                if (res.data == true) {
                                  setState(() {
                                    folderActionEnable = false;
                                    selectedRawIndex = '';
                                  });
                                  listFolderList(
                                      widget.token, callMasterId, listPath);
                                  if (mounted) Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('Rename',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                final res = await HttpService.deleteLeadFolderAndFiles(
                    widget.token, callMasterId, deletePath, rawId);
                if (res.data == true) {
                  setState(() {
                    folderActionEnable = false;
                    selectedRawIndex = '';
                  });
                  listFolderList(widget.token, callMasterId, listPath);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _viewDocument(dynamic item) {
    if (item.extension == 'M4A' || item.extension == 'm4a') {
      _showAudioPlayer(item);
    } else {
      Get.to(() => DocumentViewerScreen(
            documentUrl: item.path.toString(),
            title: item.name.toString(),
            extension: item.extension.toString(),
          ));
    }
  }

  void _showAudioPlayer(dynamic item) {
    showGeneralDialog(
      barrierLabel: "AudioPlayer",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Obx(() {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name ?? 'Audio',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            audioCreateController.stopTimer();
                            audioCreateController.audioPlayer.stop();
                            audioCreateController.resetTimer();
                            isPlay = false;
                            Get.back();
                          },
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.redAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${audioCreateController.minutes.value.toString().padLeft(2, '0')}:${audioCreateController.seconds.value.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isPlay)
                          FloatingActionButton(
                            heroTag: "play",
                            onPressed: () {
                              setState(() => isPlay = true);
                              audioCreateController.playVoice(item.path);
                            },
                            backgroundColor: const Color(0xFF2a86c9),
                            child: const Icon(Icons.play_arrow_rounded,
                                size: 36, color: Colors.white),
                          )
                        else
                          const SizedBox(),
                        const SizedBox(width: 24),
                        FloatingActionButton(
                          heroTag: "stop",
                          onPressed: () {
                            audioCreateController.stopTimer();
                            audioCreateController.audioPlayer.stop();
                            audioCreateController.resetTimer();
                            setState(() => isPlay = false);
                          },
                          backgroundColor: Colors.red.shade50,
                          elevation: 0,
                          child: const Icon(Icons.stop_rounded,
                              size: 32, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget _getFileIcon(dynamic item) {
    String assetPath = 'assets/icons/picture.png';
    if (item.isFolder == 'Y') {
      assetPath = 'assets/icons/folder.png';
    } else if (item.extension == 'M4A' || item.extension == 'm4a') {
      assetPath = 'assets/icons/audio.png';
    } else if (item.extension == 'doc' || item.extension == 'docx') {
      assetPath = 'assets/icons/doc.png';
    } else if (item.extension == 'pdf' || item.extension == 'PDF') {
      assetPath = 'assets/icons/pdf.png';
    }

    return Image.asset(
      assetPath,
      height: 48,
      width: 48,
      fit: BoxFit.contain,
    );
  }

  Widget _buildMilestonesTab() {
    if (mileStone == null || mileStone!.data!.leadMilestones!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No milestones found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mileStone!.data!.leadMilestones!.length,
      itemBuilder: (BuildContext context, int index) {
        final milestone = mileStone!.data!.leadMilestones![index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  milestone.milestone ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2a86c9),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildMilestoneDetail('Date', milestone.dateTime ?? '-'),
                    _buildMilestoneDetail('Remarks', milestone.remarks ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusId) {
    switch (statusId) {
      case '1':
        return Colors.teal;
      case '2':
        return Colors.blue;
      case '3':
        return Colors.amber;
      case '4':
        return Colors.red;
      case '5':
        return Colors.purple;
      case '6':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _handleCallAction() async {
    if (leadDetails!.data!.callPermission == false) {
      _showCallPermissionDialog();
      return;
    }

    if (widget.cloudCall) {
      _showCallTypeDialog();
    } else {
      Common.dialPad(leadDetails!.data!.contactNumber1.toString());
    }
  }

  void _showCallTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Call Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blue),
                title: const Text('Cloud Call'),
                onTap: () async {
                  Navigator.pop(context);
                  Common.showProgressDialog(context, "Loading..");

                  final result = await HttpService.addCloudCall(
                    widget.token,
                    widget.callMasterId,
                    leadDetails!.data!.contactNumber1,
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Close progress dialog

                    if (result.data == true) {
                      Common.toastMessaage(result.message, Colors.green);
                      Navigator.pop(context); // Close popup
                    } else {
                      Common.toastMessaage(result.message, Colors.red);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Phone Call'),
                onTap: () {
                  Navigator.pop(context);
                  Common.dialPad(leadDetails!.data!.contactNumber1.toString());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCallPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: Text(leadDetails!.data!.warningMessage.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close permission dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFollowup(
                      widget.token,
                      widget.editLead,
                      widget.deleteLead,
                      widget.cloudCall,
                      leadDetails!.data!.callLeadId.toString(),
                      pageName: widget.pageName,
                      status: widget.status,
                      staff: widget.staff,
                      isCalled: widget.isCalled,
                      fromDate: widget.fromDate,
                      toDate: widget.toDate,
                      category: widget.category,
                      leadType1: widget.leadType,
                    ),
                  ),
                ).then((_) {
                  widget.onDataChanged();
                  Navigator.pop(context); // Close popup
                });
              },
              child: const Text('Followup'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog() {
    TextEditingController remarkController = TextEditingController();
    String? selectedStaff;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Transfer Lead'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Staff',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedStaff,
                    items: commonDetails?.data.transferStaffs.map((staff) {
                      return DropdownMenuItem<String>(
                        value: staff.tranStaffId,
                        child: Text(staff.tranStaffName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStaff = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedStaff == null) {
                      Common.toastMessaage('Please select staff', Colors.red);
                      return;
                    }

                    Navigator.pop(context); // Close dialog
                    Common.showProgressDialog(context, "Transferring...");

                    final result = await HttpService.leadTransfer(
                      widget.token,
                      widget.callMasterId,
                      selectedStaff!,
                      remarkController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Close progress dialog

                      if (result.status == true) {
                        Common.toastMessaage(result.message, Colors.green);
                        widget.onDataChanged();
                        Navigator.pop(context); // Close popup
                      } else {
                        Common.toastMessaage(result.message, Colors.red);
                      }
                    }
                  },
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPermissionDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: Text(
            'You have no permission to access $feature. Please contact the support team.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> createOrderDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text(
                "CONFIRM",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Would you like to proceed without adding a sale?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                postFollowup();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Object?> addProductsDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox()
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "add");
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    productName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              productCalculation();
                            },
                            controller: productTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: productTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: productTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (productName == "Choose Product") {
                              Common.toastMessaage('Add a product', Colors.red);
                            } else if (productRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (productQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (productTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (double.parse(productTaxPercent.text) >
                                    100 ||
                                double.parse(productTaxPercent.text) < 0) {
                              Common.toastMessaage(
                                  'Enter valid tax percentage', Colors.red);
                            } else {
                              products.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });
                              renProducts.add({
                                "product_name": productName,
                                "product_id": productId,
                                "description": productDescription.text,
                                "product_rate": productRate.text,
                                "quantity": productQty.text,
                                "tax_percent": productTaxPercent.text,
                                "total_tax_amount": productTaxAmount.text,
                                "total_amount": productTotalAmount.text,
                              });

                              subTotal += double.parse(
                                      productTotalAmountTotal.text.isEmpty
                                          ? "0"
                                          : productTotalAmountTotal.text) *
                                  double.parse(productQty.text);
                              subTotalGrand +=
                                  double.parse(productTotalAmount.text);
                              totalTaxAmount +=
                                  double.parse(productTaxAmount.text) *
                                      double.parse(productQty.text);
                              allTotal = subTotalGrand +
                                  double.parse(shippingCharge.text == ''
                                      ? '0'
                                      : shippingCharge.text) -
                                  double.parse(discount.text == ''
                                      ? '0'
                                      : discount.text);
                              paidAmount.text = allTotal.toString();

                              productName = "Choose Product";
                              productId = "";
                              productDescription.clear();
                              productRate.clear();
                              productQty.clear();
                              productTaxPercent.clear();
                              productTaxAmount.clear();
                              productTotalAmount.clear();

                              if (typeDuration.isNotEmpty) {
                                final endValue = DateTime.now().add(
                                    Duration(days: int.parse(typeDuration)));
                                endDate.text =
                                    DateFormat('dd-MM-yyyy').format(endValue);
                              }
                              Navigator.of(context).pop();
                              this.setState(() {});
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 25, right: 25),
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Future<dynamic> productDialog(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Icon(Icons.close)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) {
                          setState(() {
                            filteredProducts = productsList
                                .where((item) => item.productName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFFCFBFA)),
                          child: ListTile(
                            onTap: () {
                              if (type == "add") {
                                if (productQty.text == "") {
                                  productQty.text = "1";
                                }
                                productName =
                                    filteredProducts[index].productName;
                                productId = filteredProducts[index].id;
                                productRate.text =
                                    filteredProducts[index].sellingPrice;
                                productTaxPercent.text =
                                    filteredProducts[index].taxPercent;
                                productTaxAmount.text =
                                    filteredProducts[index].taxAmount;
                                productTotalAmountTotal.text =
                                    ((double.parse(productRate.text)) *
                                            double.parse(productQty.text))
                                        .toString();
                                productTotalAmount.text =
                                    ((double.parse(productRate.text) +
                                                double.parse(
                                                    productTaxAmount.text)) *
                                            double.parse(productQty.text))
                                        .toString();
                                productTotalAmount.text =
                                    double.parse(productTotalAmount.text)
                                        .toStringAsFixed(2);
                                if (paymentStatus == "paid") {
                                  paidAmount.text = productTotalAmount.text;
                                }
                                typeDuration = filteredProducts[index].noOfDays;
                              } else {
                                if (renProductQty.text == "") {
                                  renProductQty.text = "1";
                                }
                                renProductName =
                                    filteredProducts[index].productName;
                                renProductId = filteredProducts[index].id;
                                renProductRate.text =
                                    filteredProducts[index].sellingPrice;
                                renProductTaxPercent.text =
                                    filteredProducts[index].taxPercent;
                                renProductTaxAmount.text =
                                    filteredProducts[index].taxAmount;
                                renProductTotalAmount.text =
                                    ((double.parse(renProductRate.text) +
                                                double.parse(
                                                    renProductTaxAmount.text)) *
                                            double.parse(renProductQty.text))
                                        .toString();
                                renProductTotalAmount.text =
                                    double.parse(renProductTotalAmount.text)
                                        .toStringAsFixed(2);
                              }
                              this.setState(() {});
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            title: Text(filteredProducts[index].productName),
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child:
                                  Text(filteredProducts[index].productName[0]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  Future<Object?> changeAmount(
      BuildContext context,
      String name,
      String rate,
      String qty,
      String tax,
      String taxPerccent,
      String amount,
      String id,
      String des,
      int index) {
    renProductQty.text = qty;
    renProductRate.text = rate;
    renProductTaxPercent.text = taxPerccent;
    renProductTaxAmount.text = tax;
    renProductTotalAmount.text = amount;
    renProductId = id;
    renProductName = name;
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(builder: (context, setState) {
          return Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: AlertDialog(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              renProducts.removeAt(index);
                              this.setState(() {});
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        productDialog(context, "edit");
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    renProductName,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation();
                            },
                            controller: renProductRate,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Rate',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation();
                            },
                            controller: renProductQty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Qty',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            onChanged: (value) {
                              renProductCalculation();
                            },
                            controller: renProductTaxPercent,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Percent',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: renProductTaxAmount,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Tax Amount',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      child: TextFormField(
                        controller: renProductTotalAmount,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 2, bottom: 2),
                            labelText: 'Total Amount',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 30, right: 30),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (renProductRate.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Rate', Colors.red);
                            } else if (renProductQty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Qty', Colors.red);
                            } else if (renProductTaxPercent.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Percent', Colors.red);
                            } else if (renProductTaxAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Tax Amount', Colors.red);
                            } else if (renProductTotalAmount.text.isEmpty) {
                              Common.toastMessaage(
                                  'Enter Product Total Amount', Colors.red);
                            } else {
                              renProducts[index] = {
                                "product_name": renProductName,
                                "product_id": renProductId,
                                "description": des,
                                "product_rate": renProductRate.text,
                                "quantity": renProductQty.text,
                                "tax_percent": renProductTaxPercent.text,
                                "total_tax_amount": renProductTaxAmount.text,
                                "total_amount": renProductTotalAmount.text,
                              };
                              Navigator.of(context).pop();
                              this.setState(() {});
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 25, right: 25),
                                child: Text(
                                  'Change',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  Future<dynamic> dropDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      height: 40,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onChanged: ((value) {
                          setState(() {
                            filterTemplates(value);
                          });
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          reminderTemplate.text =
                              filteredTemplates[index].templateName;
                          templateId = filteredTemplates[index].id;
                          Navigator.pop(context);
                          filterTemplates("");
                        },
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            filteredTemplates[index].templateName.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  void filterTemplates(String query) {
    if (detailsResponse != null) {
      filteredTemplates = detailsResponse!.data.template
          .where((map) =>
              map.templateName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<dynamic> collectedStaffDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (value) {
                      setState(() {
                        filteredStaffList = commonDetails!.data.colloctedStaff
                            .where((item) => item.accountName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredStaffList.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            this.setState(() {
                              staffName = filteredStaffList[index].accountName;
                              staffId = filteredStaffList[index].accountId;
                              filteredStaffList.clear();
                              filteredStaffList
                                  .addAll(commonDetails!.data.colloctedStaff);
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaffList[index].accountName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    filteredStaffList.clear();
                    filteredStaffList
                        .addAll(commonDetails!.data.colloctedStaff);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close")),
            ],
          );
        });
      },
    );
  }

  Future<dynamic> targetGroupDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        setState(() {
                          filteredTargetsList = commonDetails!.data.targetGroups
                              .where((item) => item.groupName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .32,
                    width: MediaQuery.of(context).size.width * .8,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredTargetsList.length,
                      itemBuilder: (context, ind) {
                        return CheckboxListTile(
                          title: SizedBox(
                            width: 200,
                            child: Text(
                              filteredTargetsList[ind].groupName.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ),
                          value: targetGroups.contains(
                                  filteredTargetsList[ind].id.toString())
                              ? true
                              : false,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                targetGroups.add(
                                    filteredTargetsList[ind].id.toString());
                                targetGroupNames.add(filteredTargetsList[ind]
                                    .groupName
                                    .toString());
                              } else {
                                targetGroups.remove(
                                    filteredTargetsList[ind].id.toString());
                                targetGroupNames.remove(filteredTargetsList[ind]
                                    .groupName
                                    .toString());
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  filteredTargetsList.clear();
                  filteredTargetsList.addAll(commonDetails!.data.targetGroups);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Done"),
              ),
            ],
          );
        });
      },
    );
  }

  productCalculation() {
    productTaxAmount.text =
        ((double.parse(productRate.text == "" ? "0" : productRate.text) *
                    double.parse(productTaxPercent.text == ""
                        ? "0"
                        : productTaxPercent.text) /
                    100) *
                double.parse(productQty.text == "" ? "0" : productQty.text))
            .toString();
    productTotalAmount.text = ((double.parse(
                    productRate.text == "" ? "0" : productRate.text) *
                double.parse(productQty.text == "" ? "0" : productQty.text)) +
            double.parse(productTaxAmount.text))
        .toString();
    productTotalAmount.text =
        double.parse(productTotalAmount.text).toStringAsFixed(2);
    setState(() {});
  }

  renProductCalculation() {
    renProductTaxAmount.text = ((double.parse(
                    renProductRate.text == "" ? "0" : renProductRate.text) *
                double.parse(renProductTaxPercent.text == ""
                    ? "0"
                    : renProductTaxPercent.text) /
                100) *
            double.parse(renProductQty.text == "" ? "0" : renProductQty.text))
        .toString();
    renProductTotalAmount.text =
        ((double.parse(renProductRate.text == "" ? "0" : renProductRate.text) *
                    double.parse(
                        renProductQty.text == "" ? "0" : renProductQty.text)) +
                double.parse(renProductTaxAmount.text))
            .toString();
    renProductTotalAmount.text =
        double.parse(renProductTotalAmount.text).toStringAsFixed(2);
    setState(() {});
  }

  Future<dynamic> contactPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Permission",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Our app accesses your contact list to help you easily add leads to our CRM system. This feature allows you to select contacts from your address book and save them as leads in the CRM, making it easier to manage your client relationships.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xffe94040)),
                              child: const Center(
                                child: Text("Deny",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              contactPermission = "true";
                              Navigator.pop(context);
                              setState(() {
                                Common.saveSharedPref(
                                    "saveContactPermission", 'true');
                                saveContactDialog(context);
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.green),
                              child: const Center(
                                child: Text("Allow",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Object?> saveContactDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: IntrinsicHeight(
                  child: Container(
                    width: double.maxFinite,
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Material(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Save Contact to Phone',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: contactFName,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'First Name',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          TextFormField(
                            controller: contactLName,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Last Name',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          TextFormField(
                            controller: contactMobile,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 2, bottom: 2),
                                labelText: 'Mobile Number',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(Icons.phone_android_rounded,
                                    color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 40,
                            width: double.maxFinite,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3375e0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: RawMaterialButton(
                              onPressed: () async {
                                if (contactFName.text.isEmpty) {
                                  Common.toastMessaage(
                                      'Enter the first name', Colors.red);
                                } else if (contactMobile.text.isEmpty) {
                                  Common.toastMessaage(
                                      'Enter the Mobile number', Colors.red);
                                } else {
                                  PermissionStatus permission =
                                      await Permission.contacts.status;

                                  if (permission != PermissionStatus.granted) {
                                    await Permission.contacts.request();
                                    PermissionStatus permission =
                                        await Permission.contacts.status;

                                    if (permission ==
                                        PermissionStatus.granted) {
                                      if (context.mounted) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        Common.showProgressDialog(
                                            context, "Saving...");
                                      }
                                      final newContact = Contact(
                                        name: Name(
                                          first: contactFName.text,
                                          last: contactLName.text,
                                        ),
                                        displayName:
                                            "${contactFName.text} ${contactLName.text}",
                                        phones: [Phone(contactMobile.text)],
                                      );
                                      await newContact.insert();

                                      Common.toastMessaage(
                                          'Saved', Colors.green);
                                    } else {
                                      //_handleInvalidPermissions(context);
                                    }
                                  } else {
                                    if (context.mounted) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      Common.showProgressDialog(
                                          context, "Saving...");
                                    }
                                    final newContact = Contact(
                                      name: Name(
                                        first: contactFName.text,
                                        last: contactLName.text,
                                      ),
                                      displayName:
                                          "${contactFName.text} ${contactLName.text}",
                                      phones: [Phone(contactMobile.text)],
                                    );
                                    await newContact.insert();

                                    Common.toastMessaage('Saved', Colors.green);
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  }
                                }
                              },
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
