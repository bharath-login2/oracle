import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/supplierDetailsModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/service/service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login2/screens/purchase/supplierDashboardPage.dart';

class SupplierManagementPage extends StatefulWidget {
  final String token;
  const SupplierManagementPage({super.key, required this.token});

  @override
  State<SupplierManagementPage> createState() => _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  bool _isLoading = true;
  List<SupplierData> _suppliers = [];
  List<SupplierData> _filteredSuppliers = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final response = await HttpService.getSuppliersDetails();
      if (response != null && response.data != null) {
        setState(() {
          _suppliers = response.data!;
          _applySearch();
        });
      } else {
        setState(() {
          _suppliers = [];
          _filteredSuppliers = [];
        });
      }
    } catch (e) {
      Common.toastMessaage("Error loading suppliers: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      _filteredSuppliers = _suppliers.where((s) {
        final query = _searchQuery.toLowerCase();
        return (s.supplierName?.toLowerCase().contains(query) ?? false) ||
            (s.contactPerson?.toLowerCase().contains(query) ?? false) ||
            (s.contactNo?.toLowerCase().contains(query) ?? false) ||
            (s.address?.toLowerCase().contains(query) ?? false) ||
            (s.gstNo?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _deleteSupplier(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Supplier",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Are you sure you want to delete this supplier? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Common.showProgressDialog(context, "Deleting supplier...");
      try {
        final res = await HttpService.deleteSupplier(id);
        Navigator.pop(context); // Close progress dialog
        if (res != null &&
            (res['status'] == true || res['status'] == 'success')) {
          Common.toastMessaage("Supplier deleted successfully", Colors.green);
          _loadSuppliers();
        } else {
          Common.toastMessaage(
              res?['message'] ?? "Failed to delete supplier", Colors.red);
        }
      } catch (e) {
        Navigator.pop(context);
        Common.toastMessaage("Error: $e", Colors.red);
      }
    }
  }

  void _showAddEditSupplierDialog({SupplierData? editSupplier}) {
  final bool isEdit = editSupplier != null;
  final TextEditingController nameCtrl =
      TextEditingController(text: editSupplier?.supplierName);
  final TextEditingController contactPersonCtrl =
      TextEditingController(text: editSupplier?.contactPerson);
  final TextEditingController contactNoCtrl =
      TextEditingController(text: editSupplier?.contactNo);
  final TextEditingController addressCtrl =
      TextEditingController(text: editSupplier?.address);
  final TextEditingController aadharCtrl =
      TextEditingController(text: editSupplier?.adharNo);
  final TextEditingController gstCtrl =
      TextEditingController(text: editSupplier?.gstNo);
  final TextEditingController accountCtrl =
      TextEditingController(text: editSupplier?.accNo);
  final TextEditingController ifscCtrl =
      TextEditingController(text: editSupplier?.ifscCode);
  final TextEditingController beneficiaryCtrl =
      TextEditingController(text: editSupplier?.beneficiaryName);
  final TextEditingController openingBalanceCtrl =
      TextEditingController(text: editSupplier?.openingBalance);
  
  String supplierType = editSupplier?.supplierType ?? "Intrastate"; 

  List<MaterialData> selectedMaterials = [];
  List<MaterialData> materialsList = [];
  bool isMaterialsLoading = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          if (materialsList.isEmpty && !isMaterialsLoading) {
            isMaterialsLoading = true;
            HttpService.getMaterials().then((val) {
              if (val != null && val.data != null && dialogCtx.mounted) {
                setDialogState(() {
                  materialsList = val.data!;
                  isMaterialsLoading = false;

                  // Preselect materials in edit mode
                  if (isEdit && editSupplier.materialId != null) {
                    final ids = editSupplier.materialId!
                        .split(",")
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    selectedMaterials = materialsList
                        .where((m) =>
                            m.materialId != null &&
                            ids.contains(m.materialId!.trim()))
                        .toList();
                  }
                });
              }
            }).catchError((e) {
              if (dialogCtx.mounted) {
                setDialogState(() {
                  isMaterialsLoading = false;
                });
              }
            });
          }

          Widget _buildCustomField({
            required String label,
            required String hint,
            required TextEditingController controller,
            bool isRequired = false,
            IconData? prefixIcon,
            bool isMultiline = false,
            TextInputType keyboardType = TextInputType.text,
          }) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569)),
                    ),
                    if (isRequired)
                      const Text(" *",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: isMultiline ? 3 : 1,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: prefixIcon != null
                          ? Icon(prefixIcon, color: Colors.grey, size: 18)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2a86c9), Color(0xFF1e6091)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? "Edit Supplier" : "Add Supplier",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const Text(
                          //   "Choose Material *",
                          //   style: TextStyle(
                          //       fontSize: 13,
                          //       fontWeight: FontWeight.bold,
                          //       color: Color(0xFF475569)),
                          // ),
                          // const SizedBox(height: 6),
                          // Container(
                          //   constraints: const BoxConstraints(minHeight: 44),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.grey.shade300),
                          //   ),
                          //   child:
                          //       DropdownSearch<MaterialData>.multiSelection(
                          //     items: (f, p) => materialsList,
                          //     itemAsString: (m) => m.materialName ?? "",
                          //     compareFn: (i, s) =>
                          //         i.materialId == s.materialId,
                          //     selectedItems: selectedMaterials,
                          //     onChanged: (val) => setDialogState(
                          //         () => selectedMaterials = val),
                          //     popupProps: PopupPropsMultiSelection.menu(
                          //       showSearchBox: true,
                          //       onItemAdded: (selectedItems, addedItem) {
                          //         setDialogState(() {
                          //           selectedMaterials = selectedItems;
                          //         });
                          //       },
                          //       onItemRemoved: (selectedItems, removedItem) {
                          //         setDialogState(() {
                          //           selectedMaterials = selectedItems;
                          //         });
                          //       },
                          //       validationBuilder: (ctx, selectedItems) =>
                          //           const SizedBox.shrink(),
                          //     ),
                          //     decoratorProps: DropDownDecoratorProps(
                          //       decoration: InputDecoration(
                          //         hintText: isMaterialsLoading
                          //             ? "Loading materials..."
                          //             : "Choose Material...",
                          //         hintStyle: TextStyle(
                          //             color: Colors.grey.shade400,
                          //             fontSize: 13),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //             horizontal: 12, vertical: 6),
                          //         border: InputBorder.none,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 16),
                          _buildCustomField(
                            label: "Supplier Name",
                            hint: "Enter supplier name",
                            controller: nameCtrl,
                            isRequired: true,
                            prefixIcon: Icons.business,
                          ),
                          _buildCustomField(
                            label: "Contact Person",
                            hint: "Enter contact person",
                            controller: contactPersonCtrl,
                            prefixIcon: Icons.person_outline,
                          ),
                          _buildCustomField(
                            label: "Contact No",
                            hint: "Enter contact phone number",
                            controller: contactNoCtrl,
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_android,
                          ),
                          _buildCustomField(
                            label: "Address",
                            hint: "Enter physical address",
                            controller: addressCtrl,
                            isMultiline: true,
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          
                          // Radio buttons for Intrastate/Interstate
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Supplier Type *",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569)),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text("Intrastate",
                                            style: TextStyle(fontSize: 14)),
                                        value: "Intrastate",
                                        groupValue: supplierType,
                                        onChanged: (value) {
                                          setDialogState(() {
                                            supplierType = value!;
                                          });
                                        },
                                        activeColor: const Color(0xFF2a86c9),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text("Other State",
                                            style: TextStyle(fontSize: 14)),
                                        value: "Interstate",
                                        groupValue: supplierType,
                                        onChanged: (value) {
                                          setDialogState(() {
                                            supplierType = value!;
                                          });
                                        },
                                        activeColor: const Color(0xFF2a86c9),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildCustomField(
                            label: "Aadhar No",
                            hint: "Enter Aadhar card number",
                            controller: aadharCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.credit_card,
                          ),
                          _buildCustomField(
                            label: "GST No",
                            hint: "Enter GST registration number",
                            controller: gstCtrl,
                            prefixIcon: Icons.percent,
                          ),
                          _buildCustomField(
                            label: "Account No",
                            hint: "Enter bank account number",
                            controller: accountCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.account_balance,
                          ),
                          _buildCustomField(
                            label: "IFSC Code",
                            hint: "Enter bank IFSC code",
                            controller: ifscCtrl,
                            prefixIcon: Icons.code,
                          ),
                          _buildCustomField(
                            label: "Beneficiary Name",
                            hint: "Enter beneficiary account name",
                            controller: beneficiaryCtrl,
                            prefixIcon: Icons.badge_outlined,
                          ),
                          _buildCustomField(
                            label: "Opening Balance",
                            hint: "0.00",
                            controller: openingBalanceCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            prefixIcon: Icons.monetization_on_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text("Cancel",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final contactNo = contactNoCtrl.text.trim();

                            // if (selectedMaterials.isEmpty) {
                            //   Common.toastMessaage(
                            //       "Please choose at least one material",
                            //       Colors.orange);
                            //   return;
                            // }
                            if (name.isEmpty) {
                              Common.toastMessaage(
                                  "Supplier name is required", Colors.orange);
                              return;
                            }
                            if (contactNo.isEmpty) {
                              Common.toastMessaage(
                                  "Contact number is required",
                                  Colors.orange);
                              return;
                            }
                            if (contactNo.length != 10) {
                              Common.toastMessaage(
                                  "Contact number must be exactly 10 digits", Colors.orange);
                              return;
                            }
                            final aadharNo = aadharCtrl.text.trim();
                            if (aadharNo.isNotEmpty && aadharNo.length != 12) {
                              Common.toastMessaage(
                                  "Aadhar number must be exactly 12 digits", Colors.orange);
                              return;
                            }

                            showDialog(
                              context: dialogCtx,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(
                                  child: CircularProgressIndicator()),
                            );

                            try {
                              final payload = {
                                if (isEdit) "id": editSupplier.id,
                                "material_id": selectedMaterials
                                    .map((m) => m.materialId)
                                    .join(","),
                                "supplier_name": name,
                                "contact_person":
                                    contactPersonCtrl.text.trim(),
                                "contact_no": contactNo,
                                "supplier_address": addressCtrl.text.trim(),
                                "aadhar_no": aadharCtrl.text.trim(),
                                "gst_no": gstCtrl.text.trim(),
                                "account_no": accountCtrl.text.trim(),
                                "ifsc_code": ifscCtrl.text.trim(),
                                "beneficiary_name":
                                    beneficiaryCtrl.text.trim(),
                                "opening_balance":
                                    openingBalanceCtrl.text.trim(),
                                "supplier_type": supplierType, // Add supplier type
                              };

                              final response = isEdit
                                  ? await HttpService.editSupplier(payload)
                                  : await HttpService.addSupplier(payload);

                              Navigator.pop(dialogCtx);
                              if (response != null &&
                                  (response['status'] == true ||
                                      response['status'] == 'success')) {
                                Common.toastMessaage(
                                  isEdit
                                      ? "Supplier updated successfully"
                                      : "Supplier added successfully",
                                  Colors.green,
                                );
                                Navigator.pop(dialogCtx);
                                _loadSuppliers();
                              } else {
                                Common.toastMessaage(
                                    response?['message'] ??
                                        "Failed to save supplier",
                                    Colors.red);
                              }
                            } catch (e) {
                              Navigator.pop(dialogCtx);
                              Common.toastMessaage(
                                  "Error saving supplier: $e", Colors.red);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a86c9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(isEdit ? "Update" : "Save",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  // void _showAddEditSupplierDialog({SupplierData? editSupplier}) {
  //   final bool isEdit = editSupplier != null;
  //   final TextEditingController nameCtrl =
  //       TextEditingController(text: editSupplier?.supplierName);
  //   final TextEditingController contactPersonCtrl =
  //       TextEditingController(text: editSupplier?.contactPerson);
  //   final TextEditingController contactNoCtrl =
  //       TextEditingController(text: editSupplier?.contactNo);
  //   final TextEditingController addressCtrl =
  //       TextEditingController(text: editSupplier?.address);
  //   final TextEditingController aadharCtrl =
  //       TextEditingController(text: editSupplier?.adharNo);
  //   final TextEditingController gstCtrl =
  //       TextEditingController(text: editSupplier?.gstNo);
  //   final TextEditingController accountCtrl =
  //       TextEditingController(text: editSupplier?.accNo);
  //   final TextEditingController ifscCtrl =
  //       TextEditingController(text: editSupplier?.ifscCode);
  //   final TextEditingController beneficiaryCtrl =
  //       TextEditingController(text: editSupplier?.beneficiaryName);
  //   final TextEditingController openingBalanceCtrl =
  //       TextEditingController(text: editSupplier?.openingBalance);

  //   List<MaterialData> selectedMaterials = [];
  //   List<MaterialData> materialsList = [];
  //   bool isMaterialsLoading = false;

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogCtx) {
  //       return StatefulBuilder(
  //         builder: (dialogCtx, setDialogState) {
  //           if (materialsList.isEmpty && !isMaterialsLoading) {
  //             isMaterialsLoading = true;
  //             HttpService.getMaterials().then((val) {
  //               if (val != null && val.data != null && dialogCtx.mounted) {
  //                 setDialogState(() {
  //                   materialsList = val.data!;
  //                   isMaterialsLoading = false;

  //                   // Preselect materials in edit mode
  //                   if (isEdit && editSupplier.materialId != null) {
  //                     final ids = editSupplier.materialId!
  //                         .split(",")
  //                         .map((e) => e.trim())
  //                         .where((e) => e.isNotEmpty)
  //                         .toList();
  //                     selectedMaterials = materialsList
  //                         .where((m) =>
  //                             m.materialId != null &&
  //                             ids.contains(m.materialId!.trim()))
  //                         .toList();
  //                   }
  //                 });
  //               }
  //             }).catchError((e) {
  //               if (dialogCtx.mounted) {
  //                 setDialogState(() {
  //                   isMaterialsLoading = false;
  //                 });
  //               }
  //             });
  //           }

  //           Widget _buildCustomField({
  //             required String label,
  //             required String hint,
  //             required TextEditingController controller,
  //             bool isRequired = false,
  //             IconData? prefixIcon,
  //             bool isMultiline = false,
  //             TextInputType keyboardType = TextInputType.text,
  //           }) {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Text(
  //                       label,
  //                       style: const TextStyle(
  //                           fontSize: 13,
  //                           fontWeight: FontWeight.bold,
  //                           color: Color(0xFF475569)),
  //                     ),
  //                     if (isRequired)
  //                       const Text(" *",
  //                           style: TextStyle(
  //                               color: Colors.red,
  //                               fontWeight: FontWeight.bold)),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 6),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(color: Colors.grey.shade300),
  //                   ),
  //                   child: TextField(
  //                     controller: controller,
  //                     maxLines: isMultiline ? 3 : 1,
  //                     keyboardType: keyboardType,
  //                     decoration: InputDecoration(
  //                       hintText: hint,
  //                       hintStyle: TextStyle(
  //                           color: Colors.grey.shade400, fontSize: 13),
  //                       prefixIcon: prefixIcon != null
  //                           ? Icon(prefixIcon, color: Colors.grey, size: 18)
  //                           : null,
  //                       contentPadding: const EdgeInsets.symmetric(
  //                           horizontal: 16, vertical: 12),
  //                       border: InputBorder.none,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //               ],
  //             );
  //           }

  //           return Dialog(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(24)),
  //             insetPadding:
  //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(24),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 20, vertical: 20),
  //                     decoration: const BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [Color(0xFF2a86c9), Color(0xFF1e6091)],
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                       ),
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           isEdit ? "Edit Supplier" : "Add Supplier",
  //                           style: const TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 18),
  //                         ),
  //                         IconButton(
  //                           icon: const Icon(Icons.close_rounded,
  //                               color: Colors.white),
  //                           onPressed: () => Navigator.pop(dialogCtx),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: SingleChildScrollView(
  //                       padding: const EdgeInsets.all(20),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text(
  //                             "Choose Material *",
  //                             style: TextStyle(
  //                                 fontSize: 13,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Color(0xFF475569)),
  //                           ),
  //                           const SizedBox(height: 6),
  //                           Container(
  //                             constraints: const BoxConstraints(minHeight: 44),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(10),
  //                               border: Border.all(color: Colors.grey.shade300),
  //                             ),
  //                             child:
  //                                 DropdownSearch<MaterialData>.multiSelection(
  //                               items: (f, p) => materialsList,
  //                               itemAsString: (m) => m.materialName ?? "",
  //                               compareFn: (i, s) =>
  //                                   i.materialId == s.materialId,
  //                               selectedItems: selectedMaterials,
  //                               onChanged: (val) => setDialogState(
  //                                   () => selectedMaterials = val),
  //                               popupProps: PopupPropsMultiSelection.menu(
  //                                 showSearchBox: true,
  //                                 onItemAdded: (selectedItems, addedItem) {
  //                                   setDialogState(() {
  //                                     selectedMaterials = selectedItems;
  //                                   });
  //                                 },
  //                                 onItemRemoved: (selectedItems, removedItem) {
  //                                   setDialogState(() {
  //                                     selectedMaterials = selectedItems;
  //                                   });
  //                                 },
  //                                 validationBuilder: (ctx, selectedItems) =>
  //                                     const SizedBox.shrink(),
  //                               ),
  //                               decoratorProps: DropDownDecoratorProps(
  //                                 decoration: InputDecoration(
  //                                   hintText: isMaterialsLoading
  //                                       ? "Loading materials..."
  //                                       : "Choose Material...",
  //                                   hintStyle: TextStyle(
  //                                       color: Colors.grey.shade400,
  //                                       fontSize: 13),
  //                                   contentPadding: const EdgeInsets.symmetric(
  //                                       horizontal: 12, vertical: 6),
  //                                   border: InputBorder.none,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 16),
  //                           _buildCustomField(
  //                             label: "Supplier Name",
  //                             hint: "Enter supplier name",
  //                             controller: nameCtrl,
  //                             isRequired: true,
  //                             prefixIcon: Icons.business,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Contact Person",
  //                             hint: "Enter contact person",
  //                             controller: contactPersonCtrl,
  //                             prefixIcon: Icons.person_outline,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Contact No",
  //                             hint: "Enter contact phone number",
  //                             controller: contactNoCtrl,
  //                             isRequired: true,
  //                             keyboardType: TextInputType.phone,
  //                             prefixIcon: Icons.phone_android,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Address",
  //                             hint: "Enter physical address",
  //                             controller: addressCtrl,
  //                             isMultiline: true,
  //                             prefixIcon: Icons.location_on_outlined,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Aadhar No",
  //                             hint: "Enter Aadhar card number",
  //                             controller: aadharCtrl,
  //                             keyboardType: TextInputType.number,
  //                             prefixIcon: Icons.credit_card,
  //                           ),
  //                           _buildCustomField(
  //                             label: "GST No",
  //                             hint: "Enter GST registration number",
  //                             controller: gstCtrl,
  //                             prefixIcon: Icons.percent,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Account No",
  //                             hint: "Enter bank account number",
  //                             controller: accountCtrl,
  //                             keyboardType: TextInputType.number,
  //                             prefixIcon: Icons.account_balance,
  //                           ),
  //                           _buildCustomField(
  //                             label: "IFSC Code",
  //                             hint: "Enter bank IFSC code",
  //                             controller: ifscCtrl,
  //                             prefixIcon: Icons.code,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Beneficiary Name",
  //                             hint: "Enter beneficiary account name",
  //                             controller: beneficiaryCtrl,
  //                             prefixIcon: Icons.badge_outlined,
  //                           ),
  //                           _buildCustomField(
  //                             label: "Opening Balance",
  //                             hint: "0.00",
  //                             controller: openingBalanceCtrl,
  //                             keyboardType:
  //                                 const TextInputType.numberWithOptions(
  //                                     decimal: true),
  //                             prefixIcon: Icons.monetization_on_outlined,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.all(20),
  //                     color: const Color(0xFFF8FAFC),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         ElevatedButton(
  //                           onPressed: () => Navigator.pop(dialogCtx),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.grey.shade200,
  //                             foregroundColor: Colors.grey.shade700,
  //                             elevation: 0,
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12)),
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 20, vertical: 12),
  //                           ),
  //                           child: const Text("Cancel",
  //                               style: TextStyle(fontWeight: FontWeight.bold)),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         ElevatedButton(
  //                           onPressed: () async {
  //                             final name = nameCtrl.text.trim();
  //                             final contactNo = contactNoCtrl.text.trim();

  //                             if (selectedMaterials.isEmpty) {
  //                               Common.toastMessaage(
  //                                   "Please choose at least one material",
  //                                   Colors.orange);
  //                               return;
  //                             }
  //                             if (name.isEmpty) {
  //                               Common.toastMessaage(
  //                                   "Supplier name is required", Colors.orange);
  //                               return;
  //                             }
  //                             if (contactNo.isEmpty) {
  //                               Common.toastMessaage(
  //                                   "Contact number is required",
  //                                   Colors.orange);
  //                               return;
  //                             }
  //                             if (contactNo.length != 10) {
  //                               Common.toastMessaage(
  //                                   "Contact number must be exactly 10 digits", Colors.orange);
  //                               return;
  //                             }
  //                             final aadharNo = aadharCtrl.text.trim();
  //                             if (aadharNo.isNotEmpty && aadharNo.length != 12) {
  //                               Common.toastMessaage(
  //                                   "Aadhar number must be exactly 12 digits", Colors.orange);
  //                               return;
  //                             }

  //                             showDialog(
  //                               context: dialogCtx,
  //                               barrierDismissible: false,
  //                               builder: (ctx) => const Center(
  //                                   child: CircularProgressIndicator()),
  //                             );

  //                             try {
  //                               final payload = {
  //                                 if (isEdit) "id": editSupplier.id,
  //                                 "material_id": selectedMaterials
  //                                     .map((m) => m.materialId)
  //                                     .join(","),
  //                                 "supplier_name": name,
  //                                 "contact_person":
  //                                     contactPersonCtrl.text.trim(),
  //                                 "contact_no": contactNo,
  //                                 "supplier_address": addressCtrl.text.trim(),
  //                                 "aadhar_no": aadharCtrl.text.trim(),
  //                                 "gst_no": gstCtrl.text.trim(),
  //                                 "account_no": accountCtrl.text.trim(),
  //                                 "ifsc_code": ifscCtrl.text.trim(),
  //                                 "beneficiary_name":
  //                                     beneficiaryCtrl.text.trim(),
  //                                 "opening_balance":
  //                                     openingBalanceCtrl.text.trim(),
  //                               };

  //                               final response = isEdit
  //                                   ? await HttpService.editSupplier(payload)
  //                                   : await HttpService.addSupplier(payload);

  //                               Navigator.pop(dialogCtx);
  //                               if (response != null &&
  //                                   (response['status'] == true ||
  //                                       response['status'] == 'success')) {
  //                                 Common.toastMessaage(
  //                                   isEdit
  //                                       ? "Supplier updated successfully"
  //                                       : "Supplier added successfully",
  //                                   Colors.green,
  //                                 );
  //                                 Navigator.pop(dialogCtx);
  //                                 _loadSuppliers();
  //                               } else {
  //                                 Common.toastMessaage(
  //                                     response?['message'] ??
  //                                         "Failed to save supplier",
  //                                     Colors.red);
  //                               }
  //                             } catch (e) {
  //                               Navigator.pop(dialogCtx);
  //                               Common.toastMessaage(
  //                                   "Error saving supplier: $e", Colors.red);
  //                             }
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: const Color(0xFF2a86c9),
  //                             foregroundColor: Colors.white,
  //                             elevation: 0,
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12)),
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 24, vertical: 12),
  //                           ),
  //                           child: Text(isEdit ? "Update" : "Save",
  //                               style: const TextStyle(
  //                                   fontWeight: FontWeight.bold)),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2a86c9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Suppliers",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        //centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSuppliers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadSuppliers,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: _filteredSuppliers.length,
                          itemBuilder: (context, index) {
                            return _buildSupplierCard(
                                _filteredSuppliers[index], index);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSupplierDialog(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("ADD SUPPLIER",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2a86c9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
              _applySearch();
            });
          },
          decoration: const InputDecoration(
            hintText: "Search suppliers by name, phone, address...",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Color(0xFF2a86c9)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2a86c9).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_center_outlined,
                  size: 70, color: Color(0xFF2a86c9)),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Suppliers Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? "Get started by adding your first supplier."
                  : "We couldn't find any suppliers matching your search criteria.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierCard(SupplierData supplier, int index) {
    // Elegant harmony using alternating light accent colors
    final List<Color> colors = [
      const Color(0xFF2563EB), // Sleek blue
      const Color(0xFF0D9488), // Teal
      const Color(0xFF7C3AED), // Indigo
      const Color(0xFFEA580C), // Amber-orange
    ];
    final colorAccent = colors[index % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupplierDashboardPage(
                supplier: supplier,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Accent Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorAccent.withOpacity(0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorAccent,
                    radius: 20,
                    child: Text(
                      (supplier.supplierName?.isNotEmpty == true)
                          ? supplier.supplierName![0].toUpperCase()
                          : "S",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.supplierName ?? "",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A)),
                        ),
                        if (supplier.contactPerson != null &&
                            supplier.contactPerson!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Contact: ${supplier.contactPerson}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showAddEditSupplierDialog(editSupplier: supplier);
                      } else if (val == 'delete') {
                        _deleteSupplier(supplier.id ?? "");
                      }
                    },
                    itemBuilder: (ctx) => [
                      // const PopupMenuItem(
                      //   value: 'edit',
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.edit_outlined,
                      //           size: 18, color: Colors.blue),
                      //       SizedBox(width: 10),
                      //       Text("Edit Info"),
                      //     ],
                      //   ),
                      // ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Delete Supplier"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Supplier Details List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (supplier.contactNo != null &&
                      supplier.contactNo!.isNotEmpty)
                    _buildDetailRow(Icons.phone_rounded, "Phone No",
                        supplier.contactNo!, colorAccent),
                  if (supplier.address != null && supplier.address!.isNotEmpty)
                    _buildDetailRow(Icons.location_on_rounded, "Address",
                        supplier.address!, colorAccent),
                  if (supplier.adharNo != null && supplier.adharNo!.isNotEmpty)
                    _buildDetailRow(Icons.fingerprint_rounded, "Aadhar No",
                        supplier.adharNo!, colorAccent),
                  if (supplier.gstNo != null && supplier.gstNo!.isNotEmpty)
                    _buildDetailRow(Icons.assignment_ind_rounded, "GST No",
                        supplier.gstNo!, colorAccent),
                  const Divider(height: 24, thickness: 1),
                  supplier.beneficiaryName?.isNotEmpty == true
                      ? const Text(
                          "BANK ACCOUNT DETAILS",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 1),
                        )
                      : SizedBox(),
                  const SizedBox(height: 8),
                  supplier.beneficiaryName?.isNotEmpty == true
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Beneficiary Name",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text(
                                    supplier.beneficiaryName?.isNotEmpty == true
                                        ? supplier.beneficiaryName!
                                        : "",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Account Number",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text(
                                    supplier.accNo?.isNotEmpty == true
                                        ? supplier.accNo!
                                        : "",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  const SizedBox(height: 10),
                  supplier.beneficiaryName?.isNotEmpty == true
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("IFSC Code",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text(
                                    supplier.ifscCode?.isNotEmpty == true
                                        ? supplier.ifscCode!
                                        : "",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  supplier.beneficiaryName?.isNotEmpty == true
                      ? const Divider(height: 24, thickness: 1)
                      : SizedBox(),

                  // Balance amounts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Opening Balance",
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            "₹ ${supplier.openingBalance ?? '0.00'}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Balance Amount",
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              "₹ ${supplier.balanceAmt ?? '0.00'}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
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
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent.withOpacity(0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
