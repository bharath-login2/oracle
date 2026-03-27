import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/leadSubTypeModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/widgets/AddLeadSourceDialog.dart';
import 'package:login2/widgets/addLeadCateoryPopup.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/leadProductsModel.dart';
import '../../service/service.dart';

class AddLeadsNew extends StatefulWidget {
  final String? token;
  final String? page;
  final String? leadMasterId;
  final String? clientName;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? fromDate;
  final String? toDate;
  final bool? editLead;
  final bool? deleteLead;
  final bool? cloudCall;
  final String? countryCode;
  final String? address;
  final String? email;
  final String? cost;
  final String? leadCategoryId;
  final String? leadSubCategoryId;
  final String? priorityId;
  final String? leadSourceId;
  final String? remarks;
  final String? pinCode;
  final String? stateId;
  final String? districtId;
  final String? assignedUserId;
  final String? leadCategory;
  final String? leadSubCategory;
  final String? leadSource;
  final String? priority;
  final String? stateName;
  final String? districtName;
  final String? products;
  final String? whatsappCode;
  final String? assignStaff;
  final String? postOffice;

  AddLeadsNew(this.token,
      {super.key,
      this.page,
      this.leadMasterId,
      this.clientName,
      this.phoneNumber,
      this.whatsappNumber,
      this.fromDate,
      this.toDate,
      this.editLead,
      this.deleteLead,
      this.cloudCall,
      this.countryCode,
      this.address,
      this.email,
      this.cost,
      this.leadCategoryId,
      this.leadSubCategoryId,
      this.priorityId,
      this.leadSourceId,
      this.remarks,
      this.pinCode,
      this.stateId,
      this.districtId,
      this.assignedUserId,
      this.leadCategory,
      this.leadSubCategory,
      this.leadSource,
      this.priority,
      this.stateName,
      this.districtName,
      this.products,
      this.whatsappCode,
      this.assignStaff,
      this.postOffice});

  @override
  State<AddLeadsNew> createState() => _AddLeadsNewState();
}

class _AddLeadsNewState extends State<AddLeadsNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  final ScrollController _scrollController = ScrollController();

  // Form Fields
  String leadType = 'Lead Category', leadTypeId = '';
  String leadSubType = 'Lead Sub Category', leadSubTypeId = '';
  String assignStaff = 'Assign Staff', assignStaffId = '';
  String callResult = 'New', callResultId = '1';
  String leadSource = 'Direct Entry', leadSourceId = "1";
  String priority = 'Normal', priorityId = '2';

  final TextEditingController leadTypeCtrl =
      TextEditingController(text: 'Lead Category');
  final TextEditingController leadSubTypeCtrl =
      TextEditingController(text: 'Lead Sub Category');
  final TextEditingController assignStaffCtrl =
      TextEditingController(text: 'Assign Staff');
  final TextEditingController leadSourceCtrl =
      TextEditingController(text: 'Direct Entry');
  final TextEditingController priorityCtrl =
      TextEditingController(text: 'Normal');
  final TextEditingController callResultCtrl =
      TextEditingController(text: 'New');
  String callResponse = 'Call Response', callResponseId = '';

  final TextEditingController clientNameCtrl = TextEditingController();
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController costCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController nextFollowupCtrl = TextEditingController();
  final TextEditingController timeBeforeCtrl =
      TextEditingController(text: '10');
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController callResponseCtrl = TextEditingController();
  final TextEditingController whatsappNoCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  // Additional Fields
  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];

  // Data Models
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  LeadProductSectionModel? productSectionModel;
  List<LeadProduct> _selectedProducts = [];
  TextEditingController _productSearchCtrl = TextEditingController();
  List<LeadProduct> _productSearchResults = [];

  // State
  bool isLoading = true,
      isDistrictLoading = false,
      isPinLoading = false,
      checked = false;
  String code = '91', whatsappCode = '91', roleId = '', multiBranch = '';
  String? branch;
  String? contactPermission, createLeadCategory, addLeadSource;
  String? StateId, DistrictId;

  @override
  void initState() {
    super.initState();
    clientNameCtrl.text = widget.clientName ?? "";
    contactNoCtrl.text = _trimPlus91(widget.phoneNumber ?? "");
    whatsappNoCtrl.text = _trimPlus91(widget.whatsappNumber ?? "");
    addressCtrl.text = widget.address ?? "";
    emailCtrl.text = widget.email ?? "";

    // Pre-fill fields from widget parameters
    costCtrl.text = widget.cost ?? "";
    remarkCtrl.text = widget.remarks ?? "";
    pinCodeCtrl.text = widget.pinCode ?? "";
    stateCtrl.text = widget.stateName ?? "";
    districtCtrl.text = widget.districtName ?? "";

    if (widget.leadCategory != null) {
      leadType = widget.leadCategory!;
      leadTypeCtrl.text = widget.leadCategory!;
    }
    if (widget.leadCategoryId != null) {
      leadTypeId = widget.leadCategoryId!;
    }

    if (widget.leadSubCategory != null) {
      leadSubType = widget.leadSubCategory!;
      leadSubTypeCtrl.text = widget.leadSubCategory!;
    }
    if (widget.leadSubCategoryId != null) {
      leadSubTypeId = widget.leadSubCategoryId!;
    }

    if (widget.leadSource != null) {
      leadSource = widget.leadSource!;
      leadSourceCtrl.text = widget.leadSource!;
    }
    if (widget.leadSourceId != null) {
      leadSourceId = widget.leadSourceId!;
    }

    if (widget.priority != null) {
      priority = widget.priority!;
      priorityCtrl.text = widget.priority!;
    }
    if (widget.priorityId != null) {
      priorityId = widget.priorityId!;
    }

    if (widget.assignStaff != null) {
      assignStaff = widget.assignStaff!;
      assignStaffCtrl.text = widget.assignStaff!;
    }
    if (widget.assignedUserId != null) {
      assignStaffId = widget.assignedUserId!;
    }

    if (widget.countryCode != null) {
      code = widget.countryCode!;
    }
    if (widget.whatsappCode != null) {
      whatsappCode = widget.whatsappCode!;
    } else if (widget.countryCode != null) {
      whatsappCode = widget.countryCode!;
    }

    if (widget.stateId != null) {
      StateId = widget.stateId;
    }
    if (widget.districtId != null) {
      DistrictId = widget.districtId;
    }

    _initializeData();
  }

  String _trimPlus91(String mobile) {
    if (mobile.startsWith('+91')) return mobile.substring(3);
    if (mobile.startsWith('91')) return mobile.substring(2);
    return mobile;
  }

  @override
  void dispose() {
    clientNameCtrl.dispose();
    contactNoCtrl.dispose();
    costCtrl.dispose();
    addressCtrl.dispose();
    remarkCtrl.dispose();
    pinCodeCtrl.dispose();
    nextFollowupCtrl.dispose();
    timeBeforeCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    callResponseCtrl.dispose();
    whatsappNoCtrl.dispose();
    emailCtrl.dispose();
    _productSearchCtrl.dispose();
    for (var ctrl in _additionalCtrls) ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity is List<ConnectivityResult>) {
      if (!connectivity.contains(ConnectivityResult.mobile) &&
          !connectivity.contains(ConnectivityResult.wifi)) {
        setState(() => isLoading = false);
        return;
      }
    }

    contactPermission = await Common.getSharedPref("getContactPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    addLeadSource = await Common.getSharedPref("addLeadSource");

    if (assignStaff == 'Assign Staff' || assignStaff.isEmpty) {
      assignStaff = await Common.getSharedPref("name") ?? 'Assign Staff';
    }
    if (assignStaffId.isEmpty) {
      assignStaffId = await Common.getSharedPref("userId") ?? '';
    }

    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';

    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (commonDetails != null) {
      if (widget.countryCode == null) {
        code = commonDetails!.data.countryCode.toString();
      }
      configure = await HttpService.configure(widget.token);
    }
    stateDetails = await HttpService.getState();
    productSectionModel = await HttpService.leadProductSection();

    if (widget.products != null &&
        widget.products!.isNotEmpty &&
        productSectionModel?.data != null) {
      final productIds = widget.products!.split(',');
      _selectedProducts = productSectionModel!.data!
          .where((p) => productIds.any((id) => id.trim() == p.id))
          .toList();
    }

    if (leadTypeId.isNotEmpty) {
      leadSubTypeList = await HttpService.leadSubType(leadTypeId);
    }

    if (pinCodeCtrl.text.length == 6) {
      final model = await HttpService.fetchPostOffice(pinCodeCtrl.text);
      postOffices = model?.postOffice ?? [];
      if (postOffices.isNotEmpty && widget.postOffice != null) {
        try {
          selectedPostOffice = postOffices.firstWhere(
            (po) => po.name?.toLowerCase() == widget.postOffice!.toLowerCase(),
          );
        } catch (e) {
          // If not found, keep it null
        }
      }
    }

    if (StateId != null && StateId!.isNotEmpty) {
      final result = await HttpService.getDistrict(StateId!);
      districtList = result?.data ?? [];
    }

    setState(() => isLoading = false);
  }

  String _formatDate(String dmy) {
    if (dmy.isEmpty) return dmy;
    final parts = dmy.split("-");
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', width: 150))
          : commonDetails == null || configure == null
              ? _buildNoNetworkView()
              : configure!.data!.isExpired == true
                  ? _buildExpiredView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.editLead == true ? 'Create Lead' : 'Create Lead',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildNoNetworkView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/noNetwork.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Text('No Network Found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          InkWell(
            onTap: _initializeData,
            child: Container(
              width: 120,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text('Try Again',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/main/packageimage.png',
              height: 160, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 15),
          const Text('Package Expired!',
              style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 10),
          const Text('Please contact support to upgrade your plan'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showUpgradeDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('UPGRADE'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (multiBranch == 'true' && roleId == '2') _buildBranchField(),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Client Info',
              icon: Icons.person_outline,
              children: [
                const SizedBox(height: 12),
                _buildCustomerRow(),
                const SizedBox(height: 12),
                _buildPhoneField(),
                const SizedBox(height: 12),
                _buildWhatsappField(),
                const SizedBox(height: 12),
                _buildEmailField(),
                const SizedBox(height: 12),
                _buildProductSelection(),
                const SizedBox(height: 12),
                _buildStaffCostRow(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Lead Details',
              icon: Icons.info_outline,
              children: [
                const SizedBox(height: 12),
                _buildLeadCategoryField(),
                const SizedBox(height: 12),
                if (leadSubTypeList?.data?.isNotEmpty ?? false)
                  _buildSubCategoryField(),
                const SizedBox(height: 12),
                _buildLeadSourceField(),
                const SizedBox(height: 12),
                _buildPriorityField(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Location Information',
              icon: Icons.location_on_outlined,
              children: [
                const SizedBox(height: 12),
                _buildAddressField(),
                const SizedBox(height: 12),
                _buildPinCodeField(),
                const SizedBox(height: 12),
                if (postOffices.isNotEmpty) _buildPostOfficeDropdown(),
                const SizedBox(height: 12),
                _buildLocationFields(),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Status & Followup',
              icon: Icons.assignment_outlined,
              children: [
                const SizedBox(height: 12),
                _buildRemarksField(),
                const SizedBox(height: 12),
                _buildStatusField(),
                const SizedBox(height: 12),
                if (callResultId == '2' ||
                    callResultId == '3' ||
                    callResultId == '4')
                  _buildCallResponseField(),
                const SizedBox(height: 12),
                if (callResultId == '2') _buildFollowupRow(),
              ],
            ),
            if (commonDetails?.data.additionalFields != null &&
                commonDetails!.data.additionalFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Additional Info',
                icon: Icons.more_horiz,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFields(),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSubmitButton()),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchField() {
    return DropdownButtonFormField<String>(
      value: branch,
      decoration: _inputDecoration('Select Branch', Icons.business),
      items: commonDetails!.data.branch.map((b) {
        return DropdownMenuItem(
          value: b.branchId.toString(),
          child: Text(b.branchName!),
        );
      }).toList(),
      onChanged: (value) async {
        setState(() => branch = value);
        commonDetails =
            await HttpService.addLeadCommonData(widget.token, branchId: branch);
        setState(() {});
      },
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: clientNameCtrl,
            decoration: _inputDecoration('Customer Name *', Icons.person),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => contactPermission == 'true'
              ? _selectContact()
              : _showPermissionDialog(),
          child: Container(
            height: 50,
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.contacts, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: contactNoCtrl,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Contact Number *',
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (c) => setState(() => code = c.phoneCode),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text("+$code"), const Icon(Icons.arrow_drop_down)],
            ),
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (v!.isEmpty) return 'Required';
        if (code == '91' && v.length != 10) return '10 digits required';
        return null;
      },
    );
  }

  Widget _buildWhatsappField() {
    return TextFormField(
      controller: whatsappNoCtrl,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Whatsapp Number',
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (c) => setState(() => whatsappCode = c.phoneCode),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("+$whatsappCode"),
                const Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (whatsappCode == '91' &&
            v != null &&
            v.isNotEmpty &&
            v.length != 10) {
          return 'Enter 10 digit number';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('Email', Icons.email),
      validator: (v) {
        if (v != null && v.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
            return 'Enter valid email';
          }
        }
        return null;
      },
    );
  }

  Widget _buildStaffCostRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: costCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Cost', Icons.currency_rupee),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showStaffDialog(),
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(text: assignStaff),
                decoration: _inputDecoration('Assign Staff', Icons.person),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCategoryField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () => _showCategoryDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: leadTypeCtrl,
              decoration: _inputDecoration(
                      'Lead Category', Icons.arrow_drop_down_circle_outlined)
                  .copyWith(
                suffixIcon: leadTypeId.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            leadType = 'Lead Category';
                            leadTypeId = '';
                            leadSubType = 'Lead Sub Category';
                            leadSubTypeId = '';
                            leadSubTypeList = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (createLeadCategory == 'true')
          Positioned(
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddCategoryDialog(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubCategoryField() {
    return GestureDetector(
      onTap: () => _showSubCategoryDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: leadSubTypeCtrl,
          decoration: _inputDecoration(
              'Lead Sub Category', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildLeadSourceField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () => _showSourceDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: leadSourceCtrl,
              decoration: _inputDecoration(
                  'Lead Source', Icons.arrow_drop_down_circle_outlined),
            ),
          ),
        ),
        if (addLeadSource == 'true')
          Positioned(
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddSourceDialog(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityField() {
    return GestureDetector(
      onTap: () => _showPriorityDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: priorityCtrl,
          decoration: _inputDecoration(
              'Priority', Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Address', Icons.location_on_outlined),
    );
  }

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: pinCodeCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('PIN Code', Icons.pin_drop).copyWith(
        suffixIcon: isPinLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : null,
      ),
      onChanged: (v) async {
        if (v.length == 6) {
          setState(() => isPinLoading = true);
          final model = await HttpService.fetchPostOffice(v);
          setState(() {
            isPinLoading = false;
            postalCodeModel = model;
            postOffices = model?.postOffice ?? [];
          });
        } else {
          setState(() {
            postOffices = [];
            selectedPostOffice = null;
          });
        }
      },
    );
  }

  Widget _buildPostOfficeDropdown() {
    return DropdownButtonFormField<PostOffice>(
      value: selectedPostOffice,
      decoration:
          _inputDecoration('Select Post Office', Icons.local_post_office),
      items: postOffices.map((po) {
        return DropdownMenuItem(value: po, child: Text(po.name ?? ''));
      }).toList(),
      onChanged: (v) => setState(() => selectedPostOffice = v),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showStateDialog(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: stateCtrl,
              decoration: _inputDecoration(
                  'State', Icons.arrow_drop_down_circle_outlined),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isDistrictLoading)
          const Center(child: CircularProgressIndicator())
        else if (districtList.isNotEmpty)
          DropdownButtonFormField<DistrictList>(
            value: districtList.any((d) => d.id == DistrictId)
                ? districtList.firstWhere((d) => d.id == DistrictId)
                : null,
            decoration: _inputDecoration(
                'Select District', Icons.arrow_drop_down_circle_outlined),
            hint: const Text("Select District"),
            items: districtList.map((d) {
              return DropdownMenuItem(value: d, child: Text(d.name));
            }).toList(),
            onChanged: (v) => setState(() {
              DistrictId = v?.id;
              districtCtrl.text = v?.name ?? '';
            }),
          ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: remarkCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Remarks', Icons.list),
    );
  }

  Widget _buildStatusField() {
    return GestureDetector(
      onTap: () => _showCallResultDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: callResult),
          decoration: _inputDecoration(
              // 'Lead Status', Icons.arrow_drop_down_circle_outlined),
              'Stages',
              Icons.arrow_drop_down_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildCallResponseField() {
    return GestureDetector(
      onTap: () => _showCallResponseDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: callResponseCtrl,
          decoration: _inputDecoration('Call Response', Icons.add_call),
        ),
      ),
    );
  }

  Widget _buildFollowupRow() {
    return Row(
      children: [
        Expanded(
          flex: checked ? 3 : 4,
          child: TextFormField(
            controller: nextFollowupCtrl,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  nextFollowupCtrl.text =
                      "${_formatDate(date.toString().split(' ')[0])} ${time.format(context)}";
                }
              }
            },
            decoration:
                _inputDecoration('Next Followup Date', Icons.calendar_month),
          ),
        ),
        if (checked)
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: timeBeforeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        int val = int.parse(timeBeforeCtrl.text);
                        timeBeforeCtrl.text = (val + 1).toString();
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 20),
                    ),
                    InkWell(
                      onTap: () {
                        int val = int.parse(timeBeforeCtrl.text);
                        timeBeforeCtrl.text =
                            (val > 0 ? val - 1 : 0).toString();
                      },
                      child: const Icon(Icons.arrow_drop_down, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => setState(() => checked = !checked),
          child: Icon(
            Icons.notifications,
            color: checked ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAdditionalFields() {
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      _additionalCtrls.add(TextEditingController());
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _additionalCtrls[i],
          onSaved: (v) {
            _additionalValues.add({
              "id": commonDetails!.data.additionalFields[i].id,
              "name": commonDetails!.data.additionalFields[i].fieldName,
              "value": v,
            });
          },
          decoration: _inputDecoration(
            commonDetails!.data.additionalFields[i].fieldName,
            Icons.arrow_drop_down_circle,
          ),
        ),
      );
    });
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isTransparent = false,
  }) {
    return Card(
      elevation: isTransparent ? 0 : 1,
      color: isTransparent ? Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTransparent ? 0 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTransparent)
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2a86c9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Create Lead',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text("Product Selection",
        //     style: TextStyle(
        //         fontWeight: FontWeight.w600,
        //         color: Colors.black87,
        //         fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _productSearchCtrl,
          onChanged: _onProductSearch,
          decoration: _inputDecoration('Search Product...', Icons.search,
              isDense: true),
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
                  subtitle: Text("Gé¦ ${p.totalAmount}"),
                  onTap: () => _addProduct(p),
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
                    onDeleted: () => _removeProduct(p),
                    backgroundColor: Colors.blue.shade50,
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _onProductSearch(String v) {
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

  void _addProduct(LeadProduct p) {
    setState(() {
      if (!_selectedProducts.any((item) => item.id == p.id)) {
        _selectedProducts.add(p);
      }
      _productSearchCtrl.clear();
      _productSearchResults = [];
      _calculateTotalAmount();
    });
  }

  void _removeProduct(LeadProduct p) {
    setState(() {
      _selectedProducts.removeWhere((item) => item.id == p.id);
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    double total = 0;
    for (var p in _selectedProducts) {
      String amountStr = (p.totalAmount ?? '0').replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    costCtrl.text = total.toStringAsFixed(2);
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {bool isDense = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      isDense: isDense,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 10, vertical: isDense ? 8 : 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 1),
      ),
    );
  }

  // Dialog Methods
  void _showStaffDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.staff);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Assign Staff'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = commonDetails!.data.staff
                          .where((s) => s.staffName
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(filtered[i].staffName),
                        onTap: () {
                          assignStaff = filtered[i].staffName;
                          assignStaffId = filtered[i].userId;
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Un Assigned'),
                    onTap: () {
                      setState(() {
                        assignStaff = 'Un Assigned';
                        assignStaffId = '';
                        assignStaffCtrl.text = assignStaff;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.leadCategory);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Lead Category'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = commonDetails!.data.leadCategory
                          .where((c) => c.leadCategory
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final cat = filtered[i];
                        return ListTile(
                          title: Text(cat.leadCategory),
                          onTap: () async {
                            leadSubTypeList = await HttpService.leadSubType(
                                cat.leadCategoryId.toString());
                            setState(() {
                              leadType = cat.leadCategory;
                              leadTypeCtrl.text = leadType;
                              leadTypeId = cat.leadCategoryId.toString();
                              leadSubType = 'Lead Sub Category';
                              leadSubTypeCtrl.text = leadSubType;
                              leadSubTypeId = '';
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSubCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (leadSubTypeList == null ||
        leadSubTypeList!.data == null ||
        leadSubTypeList!.data!.isEmpty) {
      Common.toastMessaage('No Sub Category found', Colors.orange);
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Lead Sub Category'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: ListView.builder(
              itemCount: leadSubTypeList!.data!.length,
              itemBuilder: (_, i) {
                final sub = leadSubTypeList!.data![i];
                return ListTile(
                  title: Text(sub.leadSubCategory ?? ''),
                  onTap: () {
                    setState(() {
                      leadSubType = sub.leadSubCategory!;
                      leadSubTypeCtrl.text = leadSubType;
                      leadSubTypeId = sub.leadSubCategoryId.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.leadSource);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Lead Source'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = commonDetails!.data.leadSource
                          .where((s) => s.leadSource
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final src = filtered[i];
                        return ListTile(
                          title: Text(src.leadSource),
                          onTap: () {
                            setState(() {
                              leadSource = src.leadSource;
                              leadSourceCtrl.text = leadSource;
                              leadSourceId = src.leadSourceId;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showPriorityDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Priority'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 200,
            child: ListView.builder(
              itemCount: commonDetails!.data.priority.length,
              itemBuilder: (_, i) {
                final p = commonDetails!.data.priority[i];
                return ListTile(
                  title: Text(p.priority),
                  onTap: () {
                    setState(() {
                      priority = p.priority;
                      priorityCtrl.text = priority;
                      priorityId = p.priorityId.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCallResultDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Stages'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: ListView.builder(
              itemCount: commonDetails!.data.callResult.length,
              itemBuilder: (_, i) {
                final cr = commonDetails!.data.callResult[i];
                return ListTile(
                  title: Text(cr.callResult),
                  onTap: () {
                    setState(() {
                      callResult = cr.callResult;
                      callResultCtrl.text = callResult;
                      callResultId = cr.callResultId.toString();
                      if (callResultId != '2') nextFollowupCtrl.clear();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCallResponseDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(commonDetails!.data.callResponseStatus);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Call Response'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = commonDetails!.data.callResponseStatus
                          .where((r) => r.callResponse
                              .toString()
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final r = filtered[i];
                        return ListTile(
                          title: Text(r.callResponse.toString()),
                          onTap: () {
                            setState(() {
                              callResponse = r.callResponse.toString();
                              callResponseId = r.callResponseId.toString();
                              callResponseCtrl.text = callResponse;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showStateDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) {
        final searchCtrl = TextEditingController();
        var filtered = List.from(stateDetails!.data);
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select State'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => setDialogState(() {
                      filtered = stateDetails!.data
                          .where((s) =>
                              s.name.toLowerCase().contains(v.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return ListTile(
                          title: Text(s.name),
                          onTap: () async {
                            Navigator.pop(context);
                            setState(() {
                              stateCtrl.text = s.name;
                              StateId = s.id;
                              DistrictId = null;
                              districtCtrl.clear();
                              districtList = [];
                              isDistrictLoading = true;
                            });
                            final result = await HttpService.getDistrict(s.id);
                            setState(() {
                              districtList = result?.data ?? [];
                              isDistrictLoading = false;
                              DistrictId = null;
                              districtCtrl.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showAddCategoryDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadCategoryDialog(
        onSubmit: (name, cost, sub) async {
          final token = await Common.getSharedPref('token');
          final response = await HttpService.postLeadCategory(name, cost, sub);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(token);
            if (commonDetails != null) {
              try {
                final newCat = commonDetails!.data.leadCategory.firstWhere(
                  (c) => c.leadCategory.toLowerCase() == name.toLowerCase(),
                );
                setState(() {
                  leadType = newCat.leadCategory;
                  leadTypeCtrl.text = leadType;
                  leadTypeId = newCat.leadCategoryId.toString();
                  if (cost.isNotEmpty) {
                    costCtrl.text = cost;
                  }
                  leadSubType = 'Lead Sub Category';
                  leadSubTypeCtrl.text = leadSubType;
                  leadSubTypeId = '';
                });

                // Load sub-categories for the new category
                leadSubTypeList = await HttpService.leadSubType(leadTypeId);

                if (sub != null &&
                    sub.isNotEmpty &&
                    leadSubTypeList?.data != null) {
                  try {
                    final newSub = leadSubTypeList!.data!.firstWhere(
                      (s) =>
                          s.leadSubCategory?.toLowerCase() == sub.toLowerCase(),
                    );
                    setState(() {
                      leadSubType = newSub.leadSubCategory!;
                      leadSubTypeCtrl.text = leadSubType;
                      leadSubTypeId = newSub.leadSubCategoryId.toString();
                    });
                  } catch (e) {
                    // Sub-category not found in refreshed list
                  }
                }
              } catch (e) {
                // Category not found in refreshed list
              }
            }
            setState(() {});
            // Navigator.pop(context); // REMOVED: AddLeadCategoryDialog already pops itself
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Category added'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (_) => AddLeadSourceDialog(
        onSubmit: (name) async {
          final token = await Common.getSharedPref('token');
          final response = await HttpService.postLeadSource(name);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(token);
            if (commonDetails != null) {
              try {
                final newSrc = commonDetails!.data.leadSource.firstWhere(
                  (s) => s.leadSource.toLowerCase() == name.toLowerCase(),
                );
                setState(() {
                  leadSource = newSrc.leadSource;
                  leadSourceCtrl.text = leadSource;
                  leadSourceId = newSrc.leadSourceId;
                });
              } catch (e) {
                // Source not found in refreshed list
              }
            }
            setState(() {});
            // Navigator.pop(context); // REMOVED: AddLeadSourceDialog already pops itself
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Permission',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 15),
                const Text(
                  'Access contacts to manage them efficiently',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Deny',
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Common.saveSharedPref('getContactPermission', 'true');
                        contactPermission = 'true';
                        _selectContact();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Allow'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upgrade Package'),
        content: const Text('Contact support to upgrade your plan'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('tel:${configure!.data!.supportTeamNumber}'),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String number =
            contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
        if (number.startsWith('+'))
          number = number.substring(number.length - 10);
        else if (number.length > 10)
          number = number.substring(number.length - 10);
        setState(() {
          contactNoCtrl.text = number;
          clientNameCtrl.text = contact.displayName;
        });
      }
    } else {
      Common.toastMessaage('Permission denied', Colors.red);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }
    _formKey.currentState!.save();

    if (multiBranch == 'true' && roleId == '2' && branch == null) {
      Common.toastMessaage('Select Branch', Colors.red);
      return;
    }

    if (callResultId == '2' && nextFollowupCtrl.text.isEmpty) {
      Common.toastMessaage('Select followup date', Colors.red);
      return;
    }

    Common.showProgressDialog(context, 'Loading...');
    final check = await HttpService.checkLeadPhoneNumber(
        widget.token, contactNoCtrl.text, code);

    if (check.data == true) {
      Navigator.pop(context);
      _showDuplicateDialog();
    } else {
      await _submitLead();
    }
  }

  void _showDuplicateDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alert!'),
        content: Text('Number already exists. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Common.showProgressDialog(context, 'Loading...');
              await _submitLead();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLead() async {
    String productIds = _selectedProducts.map((p) => p.id).join(',');

    final result = await HttpService.addLeadsNew(
      widget.token,
      branch,
      clientNameCtrl.text,
      leadTypeId,
      leadSubTypeId,
      contactNoCtrl.text,
      assignStaffId,
      costCtrl.text,
      priorityId,
      addressCtrl.text,
      pinCodeCtrl.text,
      selectedPostOffice?.name ?? '',
      remarkCtrl.text,
      callResultId,
      callResponseId,
      nextFollowupCtrl.text,
      _additionalValues,
      code,
      checked,
      timeBeforeCtrl.text,
      leadSourceId,
      stateId: StateId,
      districtId: DistrictId,
      products: productIds,
      whatsappNumber: whatsappNoCtrl.text,
      whatsappnumber_country_code: whatsappCode,
      email: emailCtrl.text,
    );

    Navigator.pop(context);
    if (result.status == true) {
      Common.toastMessaage(result.message, Colors.green);
      Navigator.pop(context);
    } else {
      Common.toastMessaage(result.message, Colors.red);
    }
  }
}
