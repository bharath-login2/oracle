import 'dart:convert';
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
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/editLeadModel.dart';
import '../../service/service.dart';

class EditLeadNew extends StatefulWidget {
  String? token;
  String callMasterId;
  bool editLeads;
  bool deleteLeads;
  bool cloudCall;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? pageName;
  bool? isCalled;
  int? scrolToIndex;
  EditLeadNew(this.token, this.callMasterId, this.editLeads, this.deleteLeads,
      this.cloudCall,
      {super.key,
      this.fromDate,
      this.toDate,
      this.status,
      this.category,
      this.staff,
      this.pageName,
      this.isCalled,
      this.scrolToIndex});

  @override
  State<EditLeadNew> createState() => _EditLeadNewState();
}

class _EditLeadNewState extends State<EditLeadNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddLeadCommonDataModel? commonDetails;
  StateModel? stateDetails;
  CommonConfigureModel? configure;
  LeadSubTypeModel? leadSubTypeList;
  LeadDeatailsModel? leadDetails;
  String leadType = 'Lead Category', leadTypeId = '';
  String leadSubType = 'Lead Sub Category', leadSubTypeId = '';
  String assignStaff = 'Assign Staff', assignStaffId = '';
  String callResult = 'New', callResultId = '1';
  String leadSource = 'Direct Entry', leadSourceId = "1";
  String priority = 'Warm', priorityId = '2';

  final TextEditingController clientNameCtrl = TextEditingController();
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController costCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController whatsappNoCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final List<TextEditingController> _additionalCtrls = [];
  final List<Map<String, dynamic>> _additionalValues = [];
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  LeadProductSectionModel? productSectionModel;
  List<LeadProduct> _selectedProducts = [];
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
    _initializeData();
  }

  @override
  void dispose() {
    clientNameCtrl.dispose();
    contactNoCtrl.dispose();
    costCtrl.dispose();
    addressCtrl.dispose();
    remarkCtrl.dispose();
    pinCodeCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    whatsappNoCtrl.dispose();
    emailCtrl.dispose();
    for (var ctrl in _additionalCtrls) ctrl.dispose();
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
    roleId = await Common.getSharedPref("roleId") ?? '';
    multiBranch = await Common.getSharedPref("multiBranch") ?? '';
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    stateDetails = await HttpService.getState();
    productSectionModel = await HttpService.leadProductSection();
    configure = await HttpService.configure(widget.token);
    leadDetails =
        await HttpService.leadDetails(widget.token, widget.callMasterId);
    if (leadDetails?.data != null) {
      final data = leadDetails!.data!;
      clientNameCtrl.text = data.clientName ?? "";
      code = data.countryCode?.toString() ?? '91';
      whatsappCode = data.whatsappNumberCountryCode?.toString() ?? '91';
      contactNoCtrl.text = Common.trimCountryCode(
          mobileNumber: data.contactNumber1 ?? "", countryCode: code);
      whatsappNoCtrl.text = data.whatsaAppNumber ?? "";
      emailCtrl.text = data.emailId ?? "";
      costCtrl.text = data.cost?.toString() ?? "";
      addressCtrl.text = data.address ?? "";
      pinCodeCtrl.text = data.pinCode ?? "";
      remarkCtrl.text = data.remarks ?? "";
      branch = data.branchId?.toString();
      leadType = data.leadCategory ?? 'Lead Category';
      leadTypeId = data.leadCategoryId?.toString() ?? '';
      leadSubType = data.leadSubCategory ?? 'Lead Sub Category';
      leadSubTypeId = data.leadSubCategoryId?.toString() ?? '';
      assignStaff = data.staffName ?? 'Assign Staff';
      assignStaffId = data.assignedUserId?.toString() ?? '';
      priority = data.priority ?? 'Normal';
      priorityId = data.priorityId?.toString() ?? '2';
      leadSource = data.leadSource ?? 'Direct Entry';
      leadSourceId = data.leadSourceId?.toString() ?? '1';
      callResult = data.callResult ?? 'New';
      callResultId = data.callResultId?.toString() ?? '1';
      if (leadTypeId.isNotEmpty) {
        leadSubTypeList = await HttpService.leadSubType(leadTypeId);
      }
      if (pinCodeCtrl.text.length == 6) {
        _loadPostOffices(pinCodeCtrl.text, initial: true);
      }
      if (data.stateId != null && data.stateId!.isNotEmpty) {
        StateId = data.stateId;
        stateCtrl.text = data.stateName ?? "";
        _loadDistricts(StateId!, initial: true);
      }
      if (data.productsOnAdd != null && data.productsOnAdd!.isNotEmpty) {
        final productIds = data.productsOnAdd!.split(',');
        if (productSectionModel?.data != null) {
          _selectedProducts = productSectionModel!.data!
              .where((p) => productIds.any((id) => id.trim() == p.id))
              .toList();
        }
      }
      final addonDet =
          await HttpService.listAddonDet(widget.token, widget.callMasterId);
      if (addonDet?.data != null) {
        for (var field in addonDet!.data.additionalFields) {
          final ctrl =
              TextEditingController(text: field.value?.toString() ?? "");
          _additionalCtrls.add(ctrl);
        }
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadPostOffices(String pin, {bool initial = false}) async {
    setState(() => isPinLoading = true);
    final model = await HttpService.fetchPostOffice(pin);
    setState(() {
      isPinLoading = false;
      postalCodeModel = model;
      postOffices = model?.postOffice ?? [];
      if (initial && leadDetails?.data?.postOffice != null) {
        selectedPostOffice = postOffices.firstWhere(
          (po) =>
              po.name?.toLowerCase() ==
              leadDetails!.data!.postOffice!.toLowerCase(),
          orElse: () => postOffices.isNotEmpty ? postOffices.first : null!,
        );
      } else if (!initial) {
        selectedPostOffice = null;
      }
    });
  }

  Future<void> _loadDistricts(String sId, {bool initial = false}) async {
    setState(() => isDistrictLoading = true);
    final result = await HttpService.getDistrict(sId);
    setState(() {
      districtList = result?.data ?? [];
      isDistrictLoading = false;
      if (initial && leadDetails?.data?.districtId != null) {
        final d = districtList.firstWhere(
          (d) => d.id == leadDetails!.data!.districtId,
          orElse: () => districtList.isNotEmpty ? districtList.first : null!,
        );
        DistrictId = d?.id;
        districtCtrl.text = d?.name ?? "";
      } else if (!initial) {
        DistrictId = null;
        districtCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', width: 150))
          : leadDetails == null || commonDetails == null || configure == null
              ? _buildNoNetworkView()
              : configure!.data!.isExpired == true
                  ? _buildExpiredView()
                  : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Lead',
          style: TextStyle(color: Colors.white, fontSize: 18)),
      backgroundColor: const Color(0xFF2a86c9),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildNoNetworkView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/noNetwork.jpg', width: 200, height: 200),
          const Text('No Network Found!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ElevatedButton(
              onPressed: _initializeData, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/main/packageimage.png', height: 160),
          const Text('Package Expired!',
              style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('UPGRADE')),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
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
              title: 'Location Info',
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
              title: 'Remarks',
              icon: Icons.list,
              children: [
                const SizedBox(height: 12),
                _buildRemarksField(),
              ],
            ),
            if (commonDetails!.data.additionalFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Additional Info',
                icon: Icons.more_horiz,
                children: [
                  const SizedBox(height: 12),
                  ..._buildAdditionalFieldsUI(),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: _buildSubmitButton()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildBranchField() {
    return DropdownButtonFormField<String>(
      value: branch,
      decoration: _inputDecoration('Select Branch', Icons.business),
      items: commonDetails!.data.branch
          .map((b) => DropdownMenuItem(
              value: b.branchId.toString(), child: Text(b.branchName!)))
          .toList(),
      onChanged: (v) => setState(() => branch = v),
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: clientNameCtrl,
                decoration: _inputDecoration('Customer Name *', Icons.person),
                validator: (v) => v!.isEmpty ? 'Required' : null)),
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
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.contacts, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: contactNoCtrl,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration('Contact Number *', Icons.phone).copyWith(
        prefix: GestureDetector(
          onTap: () => showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (c) => setState(() => code = c.phoneCode)),
          child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("+$code"),
                const Icon(Icons.arrow_drop_down)
              ])),
        ),
      ),
      validator: (v) => (v!.isEmpty)
          ? 'Required'
          : (code == '91' && v.length != 10)
              ? '10 digits'
              : null,
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
      validator: (v) => null,
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
              return 'Invalid';
            }
          }
          return null;
        });
  }

  Widget _buildStaffCostRow() {
    return Row(children: [
      Expanded(
          child: TextFormField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Cost', Icons.currency_rupee))),
      const SizedBox(width: 12),
      Expanded(
          child: GestureDetector(
              onTap: () => _showStaffDialog(),
              child: AbsorbPointer(
                  child: TextFormField(
                      controller: TextEditingController(text: assignStaff),
                      decoration:
                          _inputDecoration('Assign Staff', Icons.person))))),
    ]);
  }

  Widget _buildLeadCategoryField() =>
      Stack(alignment: Alignment.centerRight, children: [
        GestureDetector(
            onTap: () => _showCategoryDialog(),
            child: AbsorbPointer(
                child: TextFormField(
                    controller: TextEditingController(text: leadType),
                    decoration:
                        _inputDecoration('Lead Category', Icons.category)))),
        if (createLeadCategory == 'true')
          Positioned(
              right: 5,
              child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showAddCategoryDialog())),
      ]);

  Widget _buildSubCategoryField() => GestureDetector(
      onTap: () => _showSubCategoryDialog(),
      child: AbsorbPointer(
          child: TextFormField(
              controller: TextEditingController(text: leadSubType),
              decoration: _inputDecoration(
                  'Sub Category', Icons.subdirectory_arrow_right))));

  Widget _buildLeadSourceField() =>
      Stack(alignment: Alignment.centerRight, children: [
        GestureDetector(
            onTap: () => _showSourceDialog(),
            child: AbsorbPointer(
                child: TextFormField(
                    controller: TextEditingController(text: leadSource),
                    decoration:
                        _inputDecoration('Lead Source', Icons.source)))),
        if (addLeadSource == 'true')
          Positioned(
              right: 5,
              child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showAddSourceDialog())),
      ]);

  Widget _buildPriorityField() => GestureDetector(
      onTap: () => _showPriorityDialog(),
      child: AbsorbPointer(
          child: TextFormField(
              controller: TextEditingController(text: priority),
              decoration: _inputDecoration('Priority', Icons.priority_high))));

  Widget _buildAddressField() => TextFormField(
      controller: addressCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Address', Icons.home));

  Widget _buildPinCodeField() {
    return TextFormField(
      controller: pinCodeCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration('PIN Code', Icons.pin_drop).copyWith(
        suffixIcon: isPinLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : null,
      ),
      onChanged: (v) {
        if (v.length == 6)
          _loadPostOffices(v);
        else
          setState(() {
            postOffices = [];
            selectedPostOffice = null;
          });
      },
    );
  }

  Widget _buildPostOfficeDropdown() {
    return DropdownButtonFormField<PostOffice>(
        value: selectedPostOffice,
        decoration:
            _inputDecoration('Select Post Office', Icons.local_post_office),
        items: postOffices
            .map(
                (po) => DropdownMenuItem(value: po, child: Text(po.name ?? '')))
            .toList(),
        onChanged: (v) => setState(() => selectedPostOffice = v));
  }

  Widget _buildLocationFields() {
    return Column(children: [
      GestureDetector(
          onTap: () => _showStateDialog(),
          child: AbsorbPointer(
              child: TextFormField(
                  controller: stateCtrl,
                  decoration: _inputDecoration('State', Icons.map)))),
      const SizedBox(height: 12),
      if (isDistrictLoading)
        const Center(child: CircularProgressIndicator())
      else if (districtList.isNotEmpty)
        DropdownButtonFormField<DistrictList>(
            value: districtList.firstWhere((d) => d.id == DistrictId,
                orElse: () => districtList.first),
            decoration: _inputDecoration('District', Icons.location_city),
            items: districtList
                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                .toList(),
            onChanged: (v) => setState(() {
                  DistrictId = v?.id;
                  districtCtrl.text = v?.name ?? '';
                })),
    ]);
  }

  Widget _buildRemarksField() => TextFormField(
      controller: remarkCtrl,
      maxLines: 2,
      decoration: _inputDecoration('Remarks', Icons.notes));

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Products",
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showProductSelectionDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        _selectedProducts.isEmpty
                            ? "Select Products"
                            : "${_selectedProducts.length} Products Selected",
                        style: const TextStyle(color: Colors.black))),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedProducts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              children: _selectedProducts
                  .map((p) => Chip(
                      label: Text(p.productName ?? ""),
                      onDeleted: () => setState(() {
                            _selectedProducts.remove(p);
                            _updateTotalCost();
                          })))
                  .toList()),
        ],
      ],
    );
  }

  void _updateTotalCost() {
    double total = _selectedProducts.fold(
        0, (sum, p) => sum + (double.tryParse(p.totalAmount ?? '0') ?? 0));
    costCtrl.text = total.toStringAsFixed(2);
  }

  List<Widget> _buildAdditionalFieldsUI() {
    return List.generate(commonDetails!.data.additionalFields.length, (i) {
      if (_additionalCtrls.length <= i)
        _additionalCtrls.add(TextEditingController());
      final field = commonDetails!.data.additionalFields[i];
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: _additionalCtrls[i],
              decoration:
                  _inputDecoration(field.fieldName, Icons.add_box_outlined)));
    });
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: _submitLead,
      child: const Text('Update Lead',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12));

  // Dialogs
  void _showStaffDialog() => showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(commonDetails!.data.staff);
        return StatefulBuilder(
            builder: (c, setS) => AlertDialog(
                  title: const Text('Assign Staff'),
                  content: SizedBox(
                      width: 300,
                      height: 400,
                      child: Column(children: [
                        TextField(
                            controller: search,
                            decoration:
                                const InputDecoration(hintText: "Search"),
                            onChanged: (v) => setS(() => list = commonDetails!
                                .data.staff
                                .where((s) => s.staffName
                                    .toString()
                                    .toLowerCase()
                                    .contains(v.toLowerCase()))
                                .toList())),
                        Expanded(
                            child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (c, i) => ListTile(
                                    title: Text(list[i].staffName!),
                                    onTap: () {
                                      setState(() {
                                        assignStaff = list[i].staffName!;
                                        assignStaffId =
                                            list[i].userId.toString();
                                      });
                                      Navigator.pop(context);
                                    })))
                      ])),
                ));
      });

  void _showCategoryDialog() => showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(commonDetails!.data.leadCategory);
        return StatefulBuilder(
            builder: (c, setS) => AlertDialog(
                  title: const Text('Lead Category'),
                  content: SizedBox(
                      width: 300,
                      height: 400,
                      child: Column(children: [
                        TextField(
                            controller: search,
                            decoration:
                                const InputDecoration(hintText: "Search"),
                            onChanged: (v) => setS(() => list = commonDetails!
                                .data.leadCategory
                                .where((cat) => cat.leadCategory
                                    .toLowerCase()
                                    .contains(v.toLowerCase()))
                                .toList())),
                        Expanded(
                            child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (c, i) => ListTile(
                                    title: Text(list[i].leadCategory),
                                    onTap: () async {
                                      setState(() {
                                        leadType = list[i].leadCategory;
                                        leadTypeId =
                                            list[i].leadCategoryId.toString();
                                        leadSubType = 'Sub Category';
                                        leadSubTypeId = '';
                                      });
                                      Navigator.pop(context);
                                      leadSubTypeList =
                                          await HttpService.leadSubType(
                                              leadTypeId);
                                      setState(() {});
                                    })))
                      ])),
                ));
      });

  void _showSubCategoryDialog() => showDialog(
      context: context,
      builder: (_) => AlertDialog(
          title: const Text('Sub Category'),
          content: SizedBox(
              width: 300,
              height: 400,
              child: ListView.builder(
                  itemCount: leadSubTypeList?.data?.length ?? 0,
                  itemBuilder: (c, i) => ListTile(
                      title: Text(leadSubTypeList!.data![i].leadSubCategory!),
                      onTap: () {
                        setState(() {
                          leadSubType =
                              leadSubTypeList!.data![i].leadSubCategory!;
                          leadSubTypeId = leadSubTypeList!
                              .data![i].leadSubCategoryId
                              .toString();
                        });
                        Navigator.pop(context);
                      })))));

  void _showSourceDialog() => showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(commonDetails!.data.leadSource);
        return StatefulBuilder(
            builder: (c, setS) => AlertDialog(
                  title: const Text('Lead Source'),
                  content: SizedBox(
                      width: 300,
                      height: 400,
                      child: Column(children: [
                        TextField(
                            controller: search,
                            decoration:
                                const InputDecoration(hintText: "Search"),
                            onChanged: (v) => setS(() => list = commonDetails!
                                .data.leadSource
                                .where((src) => src.leadSource
                                    .toLowerCase()
                                    .contains(v.toLowerCase()))
                                .toList())),
                        Expanded(
                            child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (c, i) => ListTile(
                                    title: Text(list[i].leadSource),
                                    onTap: () {
                                      setState(() {
                                        leadSource = list[i].leadSource;
                                        leadSourceId =
                                            list[i].leadSourceId.toString();
                                      });
                                      Navigator.pop(context);
                                    })))
                      ])),
                ));
      });

  void _showPriorityDialog() => showDialog(
      context: context,
      builder: (_) => AlertDialog(
          title: const Text('Priority'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: commonDetails!.data.priority
                  .map((p) => ListTile(
                      title: Text(p.priority),
                      onTap: () {
                        setState(() {
                          priority = p.priority;
                          priorityId = p.priorityId.toString();
                        });
                        Navigator.pop(context);
                      }))
                  .toList())));

  void _showStateDialog() => showDialog(
      context: context,
      builder: (_) {
        var search = TextEditingController();
        var list = List.from(stateDetails!.data);
        return StatefulBuilder(
            builder: (c, setS) => AlertDialog(
                  title: const Text('Select State'),
                  content: SizedBox(
                      width: 300,
                      height: 400,
                      child: Column(children: [
                        TextField(
                            controller: search,
                            decoration:
                                const InputDecoration(hintText: "Search"),
                            onChanged: (v) => setS(() => list = stateDetails!
                                .data
                                .where((s) => s.name
                                    .toLowerCase()
                                    .contains(v.toLowerCase()))
                                .toList())),
                        Expanded(
                            child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (c, i) => ListTile(
                                    title: Text(list[i].name),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        stateCtrl.text = list[i].name;
                                        StateId = list[i].id;
                                      });
                                      _loadDistricts(StateId!);
                                    })))
                      ])),
                ));
      });

  void _showProductSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) {
        List<LeadProduct> filteredProducts =
            List.from(productSectionModel?.data ?? []);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Select Products"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "Search Products",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        setDialogState(() {
                          filteredProducts = productSectionModel!.data!
                              .where((p) => (p.productName ?? "")
                                  .toLowerCase()
                                  .contains(v.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (c, i) {
                          final p = filteredProducts[i];
                          final isSelected =
                              _selectedProducts.any((sp) => sp.id == p.id);
                          return CheckboxListTile(
                            title: Text(p.productName ?? ""),
                            subtitle: Text("₹${p.totalAmount}"),
                            value: isSelected,
                            onChanged: (v) {
                              setState(() {
                                if (v!) {
                                  _selectedProducts.add(p);
                                } else {
                                  _selectedProducts
                                      .removeWhere((sp) => sp.id == p.id);
                                }
                                _updateTotalCost();
                              });
                              setDialogState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AddLeadCategoryDialog(
        onSubmit: (name, cost, sub) async {
          final response = await HttpService.postLeadCategory(name, cost, sub);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(widget.token);
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
  }

  void _showAddSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AddLeadSourceDialog(
        onSubmit: (name) async {
          final response = await HttpService.postLeadSource(name);
          if (response?.status ?? false) {
            commonDetails = await HttpService.addLeadCommonData(widget.token);
            setState(() {});
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed')),
            );
          }
        },
      ),
    );
  }

  Future<void> _selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        if (fullContact != null && fullContact.phones.isNotEmpty) {
          setState(() {
            clientNameCtrl.text = fullContact.displayName;
            contactNoCtrl.text = _trimPlus91(fullContact.phones.first.number);
            whatsappNoCtrl.text = _trimPlus91(fullContact.phones.first.number);
          });
        }
      }
    }
  }

  String _trimPlus91(String m) {
    var s = m.replaceAll(' ', '').replaceAll('-', '');
    if (s.startsWith('+91')) return s.substring(3);
    if (s.startsWith('91') && s.length > 10) return s.substring(2);
    return s;
  }

  void _showPermissionDialog() => showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
              title: const Text('Permission Required'),
              content:
                  const Text('Please enable contact permission in settings'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ]));

  Future<void> _submitLead() async {
    if (!_formKey.currentState!.validate()) return;
    Common.showProgressDialog(context, "Updating...");

    _additionalValues.clear();
    for (int i = 0; i < commonDetails!.data.additionalFields.length; i++) {
      _additionalValues.add({
        "id": commonDetails!.data.additionalFields[i].id,
        "name": commonDetails!.data.additionalFields[i].fieldName,
        "value": _additionalCtrls[i].text
      });
    }

    final res = await HttpService.editLeads(
      widget.token,
      widget.callMasterId,
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
      selectedPostOffice?.name ?? "",
      remarkCtrl.text,
      _additionalValues,
      code,
      leadSourceId,
      stateId: StateId,
      districtId: DistrictId,
      products: _selectedProducts.map((p) => p.id).join(','),
      whatsappNumber: whatsappNoCtrl.text,
      whatsappnumber_country_code: whatsappCode,
      email: emailCtrl.text,
    );

    Navigator.pop(context);
    if (res?.status == true) {
      Common.toastMessaage(res!.message, Colors.green);
      Navigator.pop(context, true);
    } else {
      Common.toastMessaage(res?.message ?? "Update failed", Colors.red);
    }
  }
}
