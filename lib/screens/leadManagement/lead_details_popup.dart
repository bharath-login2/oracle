import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/models/callLogs/callLogUploadModel.dart';
import 'package:login2/models/lead_management/activityModel.dart';
import 'package:login2/models/lead_management/callDataModel.dart';
import 'package:login2/models/lead_management/deleteLeadFollowupModel.dart';
import 'package:login2/models/lead_management/deleteLeadModel.dart';
import 'package:login2/models/lead_management/deleteLeadVoiceModel.dart';
import 'package:login2/models/lead_management/get_chat_id.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart';
import 'package:login2/models/lead_management/leadTransferModel.dart';
import 'package:login2/models/lead_management/updateReminderSetings.dart';
import 'package:login2/models/lead_management/unsetReminderModel.dart';
import 'package:login2/models/lead_management/uploadAudioRecoed.dart';
import 'package:login2/models/lead_management/createFolderModel.dart';
import 'package:login2/models/lead_management/deleteFolderAndFileModel.dart';
import 'package:login2/models/lead_management/renameFolderModel.dart';
import 'package:login2/models/lead_management/addMileStoneModel.dart';
import 'package:login2/models/lead_management/deleteLeadMileStoneModel.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/screens/leadManagement/post_confirmed_followup.dart';
import 'package:login2/screens/leadManagement/editFollowup.dart';
import 'package:login2/screens/leadManagement/audio_controller.dart';
import 'package:login2/screens/leadManagement/imageUploadController.dart';
import 'package:login2/screens/leadManagement/docViewWebView.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:login2/service/service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/common.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadDetailsModelAdd.dart';
import '../../models/lead_management/leadMileStoneListModel.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/fileManagerPermissionModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../leadManagement/add_followup.dart';
import '../leadManagement/add_leads.dart';
import '../leadManagement/editLead.dart';

// Popup widget for lead details
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
  final LeadFollowupData? leadDetailsFollowup;
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
  ListFolderNameModel? listFolder;
  LeadMileStoneListModel? mileStone;
  LeadFollowupData? leadDetailsFollowup;
  AddLeadCommonDataModel? commonDetails;

  TextEditingController contactFName = TextEditingController();
  TextEditingController contactLName = TextEditingController();
  TextEditingController contactMobile = TextEditingController();
  TextEditingController transferRemark = TextEditingController();
  TextEditingController folderName = TextEditingController();
  TextEditingController fileName = TextEditingController();
  TextEditingController fileNameEdit = TextEditingController();
  TextEditingController timeBefore = TextEditingController();
  TextEditingController remarks = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    callMasterId = widget.callMasterId;
    leadDetails = widget.leadDetails;
    leadDetailsAdditional = widget.leadDetailsAdditional;
    listFolder = widget.listFolder;
    mileStone = widget.mileStone;
    leadDetailsFollowup = widget.leadDetailsFollowup;
    commonDetails = widget.commonDetails;

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
    }
  }

  int _getTabCount() {
    int count = 4; // Followup, Activities, Details, Documents
    if (leadDetails?.data?.callHistoryPermission == true) count++;
    if (mileStone?.data?.milestones?.isNotEmpty ?? false) count++;
    return count;
  }

  List<String> _getTabLabels() {
    List<String> labels = ['Followup', 'Activities', 'Details', 'Documents'];
    if (leadDetails?.data?.callHistoryPermission == true) {
      labels.insert(1, 'Call History');
    }
    if (mileStone?.data?.milestones?.isNotEmpty ?? false) {
      labels.add('Milestones');
    }
    return labels;
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
      child: Column(
        children: [
          // Header with drag handle and close button
          _buildHeader(),

          // Lead summary card
          _buildLeadSummaryCard(),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF2a86c9),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
              tabAlignment: TabAlignment.start,
              tabs: _getTabLabels().map((label) => Tab(text: label)).toList(),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowupTab(),
                if (leadDetails?.data?.callHistoryPermission == true)
                  _buildCallHistoryTab(),
                _buildActivitiesTab(),
                _buildDetailsTab(),
                _buildDocumentsTab(),
                if (mileStone?.data?.milestones?.isNotEmpty ?? false)
                  _buildMilestonesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            'Lead Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2a86c9),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadSummaryCard() {
    final data = leadDetails!.data!;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/user.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Lead info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: data.priorityId == '1'
                                ? Colors.grey
                                : data.priorityId == '2'
                                    ? Colors.green
                                    : data.priorityId == '3'
                                        ? Colors.red
                                        : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data.clientName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: data.priorityId == "4"
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.contactNumber1 ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${data.staffName ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(data.callResultId),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.callResult ?? 'New',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.call,
                label: 'Call',
                color: Colors.green,
                onTap: () => _handleCallAction(),
              ),
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit',
                color: Colors.blue,
                onTap: () {
                  if (widget.editLead) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditLead(
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
                  } else {
                    _showPermissionDialog('Edit Leads');
                  }
                },
              ),
              _buildActionButton(
                icon: Icons.transfer_within_a_station,
                label: 'Transfer',
                color: Colors.redAccent,
                onTap: () {
                  if (transferPermission == "true") {
                    _showTransferDialog();
                  } else {
                    _showPermissionDialog('transfer permission');
                  }
                },
              ),
              _buildActionButton(
                icon: Icons.add,
                label: 'Followup',
                color: Colors.orange,
                onTap: () {
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
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowupTab() {
    if (leadDetailsFollowup == null ||
        leadDetailsFollowup!.data.followUpData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No followups found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: leadDetailsFollowup!.data.followUpData.length,
      itemBuilder: (BuildContext context, int index) {
        final followup = leadDetailsFollowup!.data.followUpData[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: followup.isCalled == false
                ? Colors.green.shade50
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: followup.proPicThumb != null &&
                            followup.proPicThumb!.isNotEmpty
                        ? NetworkImage(followup.proPicThumb!)
                        : null,
                    child: followup.proPicThumb == null ||
                            followup.proPicThumb!.isEmpty
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followup.staffName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          followup.scheduledDate ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(followup.callResultId),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      followup.callResult ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Remark: ${followup.remarks ?? ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              if (followup.reason != null && followup.reason!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Reason: ${followup.reason}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivitiesTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Activities feature coming soon'),
      ),
    );
  }

  Widget _buildCallHistoryTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Call history feature coming soon'),
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
            _buildDetailRow('Assigned to', data.staffName ?? '-'),
            _buildDetailRow('Created date', data.createdDate ?? '-'),
            _buildDetailRow('Call Result', data.callResult ?? '-'),
            _buildDetailRow('Cost', data.cost ?? '-'),
            _buildDetailRow('Source', data.leadSource ?? '-'),
            _buildDetailRow('Remark', data.remarks ?? '-'),
          ]),
          const SizedBox(height: 16),
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
                    .map((field) =>
                        _buildDetailRow(field.name ?? '', field.value ?? '-'))
                    .toList()),
          ],
        ],
      ),
    );
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

  Widget _buildDocumentsTab() {
    if (listFolder == null || listFolder!.data!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No documents found'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: listFolder!.data!.length,
      itemBuilder: (BuildContext context, int index) {
        final item = listFolder!.data![index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                child: _getFileIcon(item),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  item.name ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getFileIcon(dynamic item) {
    if (item.isFolder == 'Y') {
      return Image.asset('assets/icons/folder.png',
          height: 50, width: 50, fit: BoxFit.contain);
    } else if (item.extension == 'M4A' || item.extension == 'm4a') {
      return Image.asset('assets/icons/audio.png',
          height: 50, width: 50, fit: BoxFit.contain);
    } else if (item.extension == 'doc' || item.extension == 'docx') {
      return Image.asset('assets/icons/doc.png',
          height: 50, width: 50, fit: BoxFit.contain);
    } else if (item.extension == 'pdf' || item.extension == 'PDF') {
      return Image.asset('assets/icons/pdf.png',
          height: 50, width: 50, fit: BoxFit.contain);
    } else {
      return Image.asset('assets/icons/picture.png',
          height: 50, width: 50, fit: BoxFit.contain);
    }
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
}
