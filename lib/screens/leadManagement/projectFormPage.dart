import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/clients/branchListModel.dart' as branch_model;
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/lead_management/newProjectListModel.dart';
import 'package:login2/models/lead_management/projectFormModels.dart';
import 'package:login2/service/service.dart';

class ProjectFormPage extends StatefulWidget {
  final NewProjectItem? project;

  const ProjectFormPage({super.key, this.project});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const Color primaryThemeColor = Color(0xFF2A86C9);

  bool get isEdit => widget.project != null;

  bool isLoadingOptions = true;
  bool isSubmitting = false;

  // Option lists fetched from APIs
  List<CustomerExp> customers = [];
  List<CustomerExp> filteredCustomers = [];
  List<WarrantyPeriodItem> warrantyList = [];
  List<LiabilityPeriodItem> liabilityList = [];
  List<ProjectStatusItem> projectStatusList = [];
  List<branch_model.Data> branchList = [];

  // Form Controllers
  final TextEditingController selectedCustomerController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectNoController = TextEditingController();
  final TextEditingController lpoNumberController = TextEditingController();
  final TextEditingController jobNumberController = TextEditingController();
  final TextEditingController mainContractorController = TextEditingController();
  final TextEditingController consultantController = TextEditingController();
  final TextEditingController siteAddressController = TextEditingController();
  final TextEditingController contractValueController = TextEditingController();
  final TextEditingController projectManagerController = TextEditingController();
  final TextEditingController projectEngineersController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController invoiceMilestoneController = TextEditingController();

  // Selected Dropdown values
  String? selectedCustomerId;
  String? selectedWarrantyId;
  String? selectedLiabilityId;
  String? selectedProjectStatusSlug;
  String? selectedBranchId;

  // Dates
  DateTime? startDate;
  DateTime? endDate;

  // Selected Files Map
  final Map<String, File?> selectedFiles = {
    'lpo': null,
    'price_breakdown': null,
    'drawings': null,
    'method_of_statement': null,
    'risk_assessment': null,
    'itp': null,
    'wir': null,
    'inspection_reports': null,
    'test_reports': null,
    'photos': null,
    'videos': null,
  };

  @override
  void initState() {
    super.initState();
    loadDropdownOptions();
  }

  Future<void> loadDropdownOptions() async {
    setState(() => isLoadingOptions = true);
    try {
      final token = await Common.getSharedPref('token');

      final customerResp = await HttpService.getCustomers();
      final warrantyResp = await HttpService.getWarrantyPeriodList();
      final liabilityResp = await HttpService.getLiabilityPeriodList();
      final statusResp = await HttpService.getProjectStatusList();
      final branchResp = await HttpService.getBranchList(token);

      if (customerResp != null && customerResp.status) {
        customers = customerResp.data;
        filteredCustomers = List.from(customers);
      }
      if (warrantyResp != null && warrantyResp.status) {
        warrantyList = warrantyResp.data;
      }
      if (liabilityResp != null && liabilityResp.status) {
        liabilityList = liabilityResp.data;
      }
      if (statusResp != null && statusResp.status) {
        projectStatusList = statusResp.data;
      }
      if (branchResp != null && branchResp.status == true && branchResp.data != null) {
        branchList = branchResp.data!;
      }

      // Populate fields if editing
      if (isEdit) {
        final p = widget.project!;
        projectNameController.text = p.projectName;
        siteAddressController.text = p.location;
        contractValueController.text = p.totalAmount;
        selectedCustomerId = p.clientId.isNotEmpty ? p.clientId : null;

        if (selectedCustomerId != null && customers.isNotEmpty) {
          final cust = customers.firstWhere(
            (c) => c.id == selectedCustomerId,
            orElse: () => CustomerExp(id: '', name: ''),
          );
          if (cust.id.isNotEmpty) {
            selectedCustomerController.text = cust.name;
          }
        }

        if (p.startingDate.isNotEmpty) {
          startDateController.text = p.startingDate;
          try {
            startDate = DateFormat('dd-MM-yyyy').parse(p.startingDate);
          } catch (_) {}
        }
        if (p.completionDate.isNotEmpty) {
          endDateController.text = p.completionDate;
          try {
            endDate = DateFormat('dd-MM-yyyy').parse(p.completionDate);
          } catch (_) {}
        }

        // Match project status slug if available
        if (p.workStatus.isNotEmpty && projectStatusList.isNotEmpty) {
          final matched = projectStatusList.firstWhere(
            (s) =>
                s.statusName.toLowerCase() == p.workStatus.toLowerCase() ||
                s.slugName.toLowerCase() == p.workStatus.toLowerCase(),
            orElse: () => ProjectStatusItem(
                statusName: '', slugName: '', companyId: ''),
          );
          if (matched.slugName.isNotEmpty) {
            selectedProjectStatusSlug = matched.slugName;
          }
        }
      }
    } catch (e) {
      log("Error loading form dropdown options: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingOptions = false);
      }
    }
  }

  Future<void> pickFileForKey(String key) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFiles[key] = File(result.files.single.path!);
        });
      }
    } catch (e) {
      log("File pick error for $key: $e");
    }
  }

  void filterCustomers(String query) {
    if (customers.isEmpty) return;
    final lower = query.toLowerCase();
    setState(() {
      filteredCustomers = query.isEmpty
          ? List.from(customers)
          : customers
              .where((c) => c.name.toLowerCase().contains(lower))
              .toList();
    });
  }

  Future<dynamic> dropDialogCustomers(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSt) {
            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: (q) {
                        filterCustomers(q);
                        setSt(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search Customer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: filteredCustomers.isEmpty
                    ? const Center(child: Text("No customers found"))
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return ListTile(
                            title: Text(customer.name),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': customer.id,
                                'name': customer.name,
                              });
                            },
                          );
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> submitForm() async {
    if (projectNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Project Name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCustomerId == null || selectedCustomerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Client"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final Map<String, dynamic> formMap = {
        'customer_id': selectedCustomerId,
        'project_name': projectNameController.text.trim(),
        'project_no': projectNoController.text.trim(),
        'lpo_number': lpoNumberController.text.trim(),
        'job_number': jobNumberController.text.trim(),
        'main_contractor': mainContractorController.text.trim(),
        'consultant': consultantController.text.trim(),
        'site_address': siteAddressController.text.trim(),
        'contract_value': contractValueController.text.trim(),
        'project_manager': projectManagerController.text.trim(),
        'project_engineers': projectEngineersController.text.trim(),
        'invoice_milestone': invoiceMilestoneController.text.trim(),
        if (selectedWarrantyId != null) 'warranty_period': selectedWarrantyId,
        if (selectedLiabilityId != null)
          'liability_period': selectedLiabilityId,
        if (selectedProjectStatusSlug != null)
          'project_status': selectedProjectStatusSlug,
        if (selectedBranchId != null) 'branch_id': selectedBranchId,
      };

      if (isEdit) {
        formMap['id'] = widget.project!.id;
      }

      if (startDate != null) {
        formMap['starting_date'] = DateFormat('yyyy-MM-dd').format(startDate!);
        formMap['start_date'] = DateFormat('yyyy-MM-dd').format(startDate!);
        formMap['from_date'] = DateFormat('yyyy-MM-dd').format(startDate!);
      } else if (startDateController.text.isNotEmpty) {
        formMap['starting_date'] = startDateController.text.trim();
        formMap['start_date'] = startDateController.text.trim();
        formMap['from_date'] = startDateController.text.trim();
      }

      if (endDate != null) {
        formMap['completion_date'] = DateFormat('yyyy-MM-dd').format(endDate!);
        formMap['end_date'] = DateFormat('yyyy-MM-dd').format(endDate!);
        formMap['to_date'] = DateFormat('yyyy-MM-dd').format(endDate!);
      } else if (endDateController.text.isNotEmpty) {
        formMap['completion_date'] = endDateController.text.trim();
        formMap['end_date'] = endDateController.text.trim();
        formMap['to_date'] = endDateController.text.trim();
      }

      // Attach any picked files
      for (var entry in selectedFiles.entries) {
        if (entry.value != null) {
          formMap[entry.key] =
              await MultipartFile.fromFile(entry.value!.path);
        }
      }

      final success = await HttpService.saveProjectFullData(
        formMap: formMap,
        isUpdate: isEdit,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit
                  ? "Project updated successfully!"
                  : "Project created successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit
                  ? "Failed to update project"
                  : "Failed to create project"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log("Submit form error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600, size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilePickerTile({
    required String label,
    required String fileKey,
  }) {
    final file = selectedFiles[fileKey];
    final fileName = file != null ? file.path.split('/').last : 'No file chosen';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => pickFileForKey(fileKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                child: const Text(
                  "Choose File",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    color: file != null ? Colors.black87 : Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Project" : "Add Project",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryThemeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoadingOptions
          ? const Center(child: CircularProgressIndicator(color: primaryThemeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client & Project Name Row
                  _buildFieldLabel("Client", isRequired: true),
                  GestureDetector(
                    onTap: () async {
                      final selected = await dropDialogCustomers(context);
                      if (selected != null) {
                        setState(() {
                          selectedCustomerId = selected['id'];
                          selectedCustomerController.text = selected['name'];
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: selectedCustomerController,
                          decoration: InputDecoration(
                            hintText: 'Select Client',
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildFieldLabel("Project Name", isRequired: true),
                  _buildTextField(
                    controller: projectNameController,
                    hintText: 'Enter your project name',
                    prefixIcon: Icons.business,
                  ),

                  _buildFieldLabel("Project No."),
                  _buildTextField(
                    controller: projectNoController,
                    hintText: 'Enter project number',
                  ),

                  _buildFilePickerTile(label: "LPO", fileKey: 'lpo'),

                  _buildFieldLabel("LPO Number"),
                  _buildTextField(
                    controller: lpoNumberController,
                    hintText: 'Enter LPO number',
                  ),

                  _buildFieldLabel("Job Number"),
                  _buildTextField(
                    controller: jobNumberController,
                    hintText: 'Enter job number',
                  ),

                  _buildFieldLabel("Main Contractor"),
                  _buildTextField(
                    controller: mainContractorController,
                    hintText: 'Enter main contractor name',
                  ),

                  _buildFieldLabel("Consultant"),
                  _buildTextField(
                    controller: consultantController,
                    hintText: 'Enter consultant name',
                  ),

                  _buildFieldLabel("Site Address"),
                  _buildTextField(
                    controller: siteAddressController,
                    hintText: 'Enter site address',
                  ),

                  _buildFieldLabel("Contract Value"),
                  _buildTextField(
                    controller: contractValueController,
                    hintText: 'Enter contract value',
                    keyboardType: TextInputType.number,
                  ),

                  _buildFilePickerTile(
                    label: "Unit Wise Price Breakdown",
                    fileKey: 'price_breakdown',
                  ),

                  _buildFieldLabel("Project Manager"),
                  _buildTextField(
                    controller: projectManagerController,
                    hintText: 'Enter project manager name',
                  ),

                  _buildFieldLabel("Project Engineers"),
                  _buildTextField(
                    controller: projectEngineersController,
                    hintText: 'Enter project engineers',
                  ),

                  // Dates
                  _buildFieldLabel("Contract Start Date"),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                          startDateController.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: startDateController,
                          decoration: const InputDecoration(
                            hintText: 'dd-mm-yyyy',
                            suffixIcon: Icon(Icons.calendar_month),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildFieldLabel("Completion Date"),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                          endDateController.text =
                              DateFormat('dd-MM-yyyy').format(picked);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: endDateController,
                          decoration: const InputDecoration(
                            hintText: 'dd-mm-yyyy',
                            suffixIcon: Icon(Icons.calendar_month),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Warranty Dropdown
                  _buildFieldLabel("Warranty Period"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedWarrantyId,
                        hint: const Text("Select Warranty Period"),
                        items: warrantyList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.periodName),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedWarrantyId = val),
                      ),
                    ),
                  ),

                  // Liability Dropdown
                  _buildFieldLabel("Defects Liability Period"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedLiabilityId,
                        hint: const Text("Select Defects Liability Period"),
                        items: liabilityList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.periodName),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedLiabilityId = val),
                      ),
                    ),
                  ),

                  // Project Status Dropdown
                  _buildFieldLabel("Project Status"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedProjectStatusSlug,
                        hint: const Text("Select Project Status"),
                        items: projectStatusList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.slugName,
                            child: Text(item.statusName),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedProjectStatusSlug = val),
                      ),
                    ),
                  ),

                  _buildFieldLabel("Invoice Milestone"),
                  _buildTextField(
                    controller: invoiceMilestoneController,
                    hintText: 'Enter invoice milestone',
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Document Management",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryThemeColor,
                    ),
                  ),
                  const Divider(),

                  _buildFilePickerTile(
                      label: "Drawings", fileKey: 'drawings'),
                  _buildFilePickerTile(
                      label: "Method of Statement",
                      fileKey: 'method_of_statement'),
                  _buildFilePickerTile(
                      label: "Risk Assessment", fileKey: 'risk_assessment'),
                  _buildFilePickerTile(label: "ITP", fileKey: 'itp'),
                  _buildFilePickerTile(label: "WIR", fileKey: 'wir'),
                  _buildFilePickerTile(
                      label: "Inspection Reports",
                      fileKey: 'inspection_reports'),
                  _buildFilePickerTile(
                      label: "Test Reports (TPI)", fileKey: 'test_reports'),
                  _buildFilePickerTile(label: "Photos", fileKey: 'photos'),
                  _buildFilePickerTile(label: "Videos", fileKey: 'videos'),

                  // Branch Dropdown
                  _buildFieldLabel("Branch", isRequired: true),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedBranchId,
                        hint: const Text("Select Branch"),
                        items: branchList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.branchId,
                            child: Text(item.branchName ?? ''),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedBranchId = val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isEdit ? "Update" : "Submit",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
