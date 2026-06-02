import 'package:flutter/material.dart';

import 'package:login2/core/common.dart';

import 'package:login2/models/lead_management/getPurchaseReturnModel.dart';

import 'package:login2/models/lead_management/getPurchaseReturnAddListMode.dart';

import 'package:login2/models/lead_management/materialModel.dart';

import 'package:login2/models/lead_management/getSupplierListMode.dart';

import 'package:login2/service/service.dart';

import 'package:intl/intl.dart';

import 'package:dropdown_search/dropdown_search.dart';

class PurchaseReturnPage extends StatefulWidget {
  final String token;

  final String name;

  final String userId;

  const PurchaseReturnPage({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
  });

  @override
  State<PurchaseReturnPage> createState() => _PurchaseReturnPageState();
}

class _PurchaseReturnPageState extends State<PurchaseReturnPage> {
  bool isLoading = true;

  List<PurchaseReturn> returns = [];

  List<PurchaseReturn> filteredReturns = [];

  String searchQuery = "";

  // Filters

  DateTime? fromDate;

  DateTime? toDate;

  Supplier? selectedSupplier;

  MaterialData? selectedMaterial;

  List<Supplier> suppliers = [];

  List<MaterialData> materials = [];

  @override
  void initState() {
    super.initState();

    _fetchReturns();

    _fetchSuppliers();

    _fetchMaterials();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final response = await HttpService.getSupplierList({});

      if (response != null && response.data != null) {
        setState(() {
          suppliers = response.data;
        });
      }
    } catch (e) {
      print("Error fetching suppliers: $e");
    }
  }

  Future<void> _fetchMaterials() async {
    try {
      final response = await HttpService.getMaterials();

      if (response != null && response.data != null) {
        setState(() {
          materials = response.data!;
        });
      }
    } catch (e) {
      print("Error fetching materials: $e");
    }
  }

  Future<void> _fetchReturns() async {
    setState(() => isLoading = true);

    try {
      Map<String, dynamic> data = {};

      if (fromDate != null) {
        data['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate!);
      }

      if (toDate != null) {
        data['to_date'] = DateFormat('yyyy-MM-dd').format(toDate!);
      }

      if (selectedSupplier != null) {
        data['supplier_id'] = selectedSupplier!.supplierId;
      }

      if (selectedMaterial != null) {
        data['material_id'] = selectedMaterial!.materialId;
      }

      final response = await HttpService.purchaseReturnList(data);

      if (response != null && response.data != null) {
        setState(() {
          returns = response.data;

          _applySearch();

          isLoading = false;
        });
      } else {
        setState(() {
          returns = [];

          filteredReturns = [];

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching purchase returns: $e");

      setState(() => isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      filteredReturns = returns.where((ret) {
        final query = searchQuery.toLowerCase();

        return (ret.returnId.toLowerCase().contains(query)) ||
            (ret.supplierName.toLowerCase().contains(query)) ||
            (ret.productName.toLowerCase().contains(query));
      }).toList();
    });
  }

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
          'Purchase Returns',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReturns.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchReturns,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          itemCount: filteredReturns.length,
                          itemBuilder: (context, index) {
                            return _buildReturnCard(filteredReturns[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReturnDialog,
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW RETURN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFF2a86c9),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          onChanged: (value) {
            searchQuery = value;

            _applySearch();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search purchase returns...',
            hintStyle:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnCard(PurchaseReturn ret) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2a86c9).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetailsBottomSheet(ret),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.assignment_return_rounded,
                            color: Color(0xFF2a86c9), size: 20),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RET #${ret.returnId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ret.returnDate,
                              style: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PopupMenuButton<String>(

                      //   padding: EdgeInsets.zero,

                      //   icon: Icon(Icons.more_horiz_rounded,

                      //       color: Colors.blueGrey.shade300),

                      //   shape: RoundedRectangleBorder(

                      //       borderRadius: BorderRadius.circular(15)),

                      //   onSelected: (value) {

                      //     if (value == 'edit') {

                      //       _showAddReturnDialog(editReturn: ret);

                      //     } else if (value == 'delete') {

                      //       _deleteReturn(ret.id);

                      //     }

                      //   },

                      //   itemBuilder: (context) => [

                      //     PopupMenuItem(

                      //       value: 'edit',

                      //       child: Row(

                      //         children: [

                      //           Icon(Icons.edit_note_rounded,

                      //               size: 20, color: Colors.blue.shade600),

                      //           const SizedBox(width: 12),

                      //           const Text("Edit",

                      //               style: TextStyle(fontSize: 14)),

                      //         ],

                      //       ),

                      //     ),

                      //     PopupMenuItem(

                      //       value: 'delete',

                      //       child: Row(

                      //         children: [

                      //           Icon(Icons.delete_outline_rounded,

                      //               size: 20, color: Colors.red.shade600),

                      //           const SizedBox(width: 12),

                      //           const Text("Delete",

                      //               style: TextStyle(fontSize: 14)),

                      //         ],

                      //       ),

                      //     ),

                      //   ],

                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_rounded,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ret.supplierName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_rounded,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ret.productName,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('Qty: ',
                                style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                            Text('${ret.returnQuantity} ${ret.unitName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Color(0xFF2a86c9))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('TOTAL AMOUNT',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade300,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text('₹${ret.totalRetAmt}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Color(0xFFEF4444),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.green;

    if (status.toLowerCase().contains('pending')) color = Colors.orange;

    if (status.toLowerCase().contains('cancel')) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_return_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Returns Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Returns',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Date Range',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );

                            if (date != null) {
                              setSheetState(() => fromDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(fromDate == null
                                ? 'From Date'
                                : DateFormat('dd-MM-yyyy').format(fromDate!)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: toDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );

                            if (date != null) {
                              setSheetState(() => toDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(toDate == null
                                ? 'To Date'
                                : DateFormat('dd-MM-yyyy').format(toDate!)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Supplier',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  DropdownSearch<Supplier>(
                    items: (f, p) => suppliers,
                    itemAsString: (s) => s.supplierName,
                    selectedItem: selectedSupplier,
                    compareFn: (item, selectedItem) =>
                        item.supplierId == selectedItem?.supplierId,
                    onChanged: (val) =>
                        setSheetState(() => selectedSupplier = val),
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        hintText: "Select Supplier",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Material',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  DropdownSearch<MaterialData>(
                    items: (f, p) => materials,
                    itemAsString: (m) => m.materialName ?? "",
                    selectedItem: selectedMaterial,
                    compareFn: (item, selectedItem) =>
                        item.materialId == selectedItem?.materialId,
                    onChanged: (val) =>
                        setSheetState(() => selectedMaterial = val),
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        hintText: "Select Material",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              fromDate = null;

                              toDate = null;

                              selectedSupplier = null;

                              selectedMaterial = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            _fetchReturns();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a86c9),
                          ),
                          child: const Text('Apply Filter',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddReturnDialog({PurchaseReturn? editReturn}) {
    DateTime returnDate = DateTime.now();

    Supplier? supplier;

    final billIdController = TextEditingController();

    final remarksController = TextEditingController();

    final returnIdController = TextEditingController(
        text: "#R${DateFormat('HHmmss').format(DateTime.now())}");

    List<PurchaseReturnItem> availableItems = [];

    Map<String, TextEditingController> qtyControllers = {};

    Map<String, TextEditingController> rateControllers = {};

    bool showBottomSection = false;

    bool isFetchingList = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "AddPurchaseReturn",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            double totalAmount = 0;

            if (showBottomSection) {
              for (var item in availableItems) {
                double q =
                    double.tryParse(qtyControllers[item.itemId]?.text ?? "0") ??
                        0;

                double r = double.tryParse(
                        rateControllers[item.itemId]?.text ?? "0") ??
                    0;

                totalAmount += (q * r);
              }
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2a86c9),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              editReturn != null
                                  ? "Edit Return"
                                  : "New Purchase Return",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(dialogContext),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Return Id",
                                      child: TextField(
                                        controller: returnIdController,
                                        readOnly: true,
                                        decoration: _inputDecoration("ID"),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Supplier Name*",
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: DropdownSearch<Supplier>(
                                          items: (f, p) => suppliers,
                                          itemAsString: (s) => s.supplierName,
                                          selectedItem: supplier,
                                          compareFn: (i, s) =>
                                              i.supplierId == s?.supplierId,
                                          onChanged: (val) => setDialogState(
                                              () => supplier = val),
                                          dropdownBuilder:
                                              (context, selectedItem) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                    child: Text(
                                                      selectedItem
                                                              ?.supplierName ??
                                                          "Select Supplier",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                // IconButton(
                                                //   onPressed: () =>
                                                //       _showQuickAddSupplierDialog(
                                                //     dialogContext,
                                                //     onSupplierAdded:
                                                //         (newSupplier) {
                                                //       setDialogState(() {
                                                //         suppliers
                                                //             .add(newSupplier);
                                                //         supplier = newSupplier;
                                                //       });
                                                //     },
                                                //   ),
                                                //   icon: const Icon(
                                                //       Icons.add_circle,
                                                //       color: Color(0xFF2a86c9),
                                                //       size: 24),
                                                //   padding:
                                                //       const EdgeInsets.only(
                                                //           right: 0, left: 18),
                                                //   constraints:
                                                //       const BoxConstraints(),
                                                //   tooltip: "Add New Supplier",
                                                // ),
                                              ],
                                            );
                                          },
                                          popupProps: const PopupProps.menu(
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                hintText: "Search supplier...",
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          decoratorProps:
                                              DropDownDecoratorProps(
                                            decoration:
                                                _inputDecoration("Select")
                                                    .copyWith(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Expanded(

                                  //   child: _buildInputLabelField(

                                  //     label: "Supplier Name*",

                                  //     child: DropdownSearch<Supplier>(

                                  //       items: (f, p) => suppliers,

                                  //       itemAsString: (s) => s.supplierName,

                                  //       selectedItem: supplier,

                                  //       compareFn: (i, s) => i.supplierId == s?.supplierId,

                                  //       onChanged: (val) => setDialogState(() => supplier = val),

                                  //       decoratorProps: DropDownDecoratorProps(

                                  //         decoration: _inputDecoration("Select Supplier").copyWith(

                                  //           suffixIcon: IconButton(

                                  //             onPressed: () => _showQuickAddSupplierDialog(

                                  //               dialogContext,

                                  //               onSupplierAdded: (newSupplier) {

                                  //                 setDialogState(() {

                                  //                   suppliers.add(newSupplier);

                                  //                   supplier = newSupplier;

                                  //                 });

                                  //               },

                                  //             ),

                                  //             icon: const Icon(Icons.add_circle, color: Color(0xFF2a86c9), size: 24),

                                  //             padding: EdgeInsets.zero,

                                  //             constraints: const BoxConstraints(),

                                  //           ),

                                  //         ),

                                  //       ),

                                  //     ),

                                  //   ),

                                  // ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Bill Id*",
                                      child: TextField(
                                        controller: billIdController,
                                        decoration: _inputDecoration("#0000"),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Return Date*",
                                      child: InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: dialogContext,
                                            initialDate: returnDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime.now(),
                                          );

                                          if (date != null)
                                            setDialogState(
                                                () => returnDate = date);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 16, color: Colors.grey),
                                              const SizedBox(width: 10),
                                              Text(DateFormat('dd-MM-yyyy')
                                                  .format(returnDate)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 120,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: isFetchingList
                                      ? null
                                      : () async {
                                          if (supplier == null ||
                                              billIdController.text.isEmpty) {
                                            Common.toastMessaage(
                                                "Select supplier and enter Bill ID",
                                                Colors.orange);

                                            return;
                                          }

                                          setDialogState(
                                              () => isFetchingList = true);

                                          try {
                                            final response = await HttpService
                                                .purchaseReturngetForAdd({
                                              "supplier_id":
                                                  supplier!.supplierId,
                                              "bill_no": billIdController.text,
                                            });

                                            setDialogState(() {
                                              isFetchingList = false;

                                              if (response != null &&
                                                  response.status) {
                                                availableItems = response.data;

                                                qtyControllers.clear();

                                                rateControllers.clear();

                                                for (var item
                                                    in availableItems) {
                                                  qtyControllers[item.itemId] =
                                                      TextEditingController(
                                                          text: "0");

                                                  rateControllers[item.itemId] =
                                                      TextEditingController(
                                                          text: item.unitPrice);
                                                }

                                                showBottomSection =
                                                    availableItems.isNotEmpty;

                                                if (!showBottomSection) {
                                                  Common.toastMessaage(
                                                      "No materials found for this bill",
                                                      Colors.orange);
                                                }
                                              } else {
                                                showBottomSection = false;

                                                Common.toastMessaage(
                                                    response?.message ??
                                                        "Error fetching items",
                                                    Colors.red);
                                              }
                                            });
                                          } catch (e) {
                                            setDialogState(
                                                () => isFetchingList = false);

                                            Common.toastMessaage(
                                                "Error: $e", Colors.red);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2a86c9),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: isFetchingList
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text("Get List",
                                          style:
                                              TextStyle(color: Colors.white)),
                                ),
                              ),
                              if (showBottomSection) ...[
                                const Divider(height: 40),
                                const Text("LIST OF MATERIALS AVAILABLE",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                                const SizedBox(height: 10),
                                Scrollbar(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                          Colors.grey.shade50),
                                      columnSpacing: 20,
                                      horizontalMargin: 10,
                                      columns: const [
                                        DataColumn(
                                            label: Text("#",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Material",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Unit",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Unit\nPrice",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text(
                                                "Available Stock\n(Qty | Amt)",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Returned Qty",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Rate(w/o GST)",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Total Amt",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ],
                                      rows: List.generate(availableItems.length,
                                          (index) {
                                        final item = availableItems[index];

                                        double q = double.tryParse(
                                                qtyControllers[item.itemId]
                                                        ?.text ??
                                                    "0") ??
                                            0;

                                        double r = double.tryParse(
                                                rateControllers[item.itemId]
                                                        ?.text ??
                                                    "0") ??
                                            0;

                                        double rowTotal = q * r;

                                        return DataRow(cells: [
                                          DataCell(Text("${index + 1}",
                                              style: const TextStyle(
                                                  fontSize: 11))),
                                          DataCell(Text(item.materialName,
                                              style: const TextStyle(
                                                  fontSize: 11))),
                                          DataCell(Text(item.unitName,
                                              style: const TextStyle(
                                                  fontSize: 11))),
                                          DataCell(Text(item.unitPrice,
                                              style: const TextStyle(
                                                  fontSize: 11))),
                                          DataCell(Text(
                                              "${item.quantity} | ${item.totalAmount}",
                                              style: const TextStyle(
                                                  fontSize: 11))),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 16,
                                                      color: Colors.red),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    double curr = double.tryParse(
                                                            qtyControllers[item
                                                                        .itemId]
                                                                    ?.text ??
                                                                "0") ??
                                                        0;

                                                    if (curr > 0) {
                                                      setDialogState(() {
                                                        double newVal =
                                                            curr - 1;

                                                        qtyControllers[
                                                                item.itemId]
                                                            ?.text = newVal ==
                                                                newVal.toInt()
                                                            ? newVal
                                                                .toInt()
                                                                .toString()
                                                            : newVal.toString();
                                                      });
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 4),
                                                SizedBox(
                                                  width: 50,
                                                  child: TextField(
                                                    controller: qtyControllers[
                                                        item.itemId],
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        _tableInputDecoration()
                                                            .copyWith(
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 4),
                                                    ),
                                                    onChanged: (v) =>
                                                        setDialogState(() {}),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      size: 16,
                                                      color: Colors.green),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    double curr = double.tryParse(
                                                            qtyControllers[item
                                                                        .itemId]
                                                                    ?.text ??
                                                                "0") ??
                                                        0;

                                                    setDialogState(() {
                                                      double newVal = curr + 1;

                                                      qtyControllers[
                                                              item.itemId]
                                                          ?.text = newVal ==
                                                              newVal.toInt()
                                                          ? newVal
                                                              .toInt()
                                                              .toString()
                                                          : newVal.toString();
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(SizedBox(
                                            width: 100,
                                            child: TextField(
                                              controller:
                                                  rateControllers[item.itemId],
                                              keyboardType:
                                                  TextInputType.number,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              decoration:
                                                  _tableInputDecoration(),
                                              onChanged: (v) =>
                                                  setDialogState(() {}),
                                            ),
                                          )),
                                          DataCell(Text(
                                              rowTotal.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                        ]);
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text("SUMMARY",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Supplier",
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                              supplier?.supplierName ?? "",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Total Amount",
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                              "₹ ${totalAmount.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF2a86c9))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF2a86c9)
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          color: Color(0xFF2a86c9), size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Total Amount will be Credited to Supplier Advance. You can Redeem Advance at the time of Purchase Bill creation.",
                                          style: TextStyle(
                                              color: const Color(0xFF2a86c9),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildInputLabelField(
                                  label: "Remarks",
                                  child: TextField(
                                    controller: remarksController,
                                    maxLines: 2,
                                    decoration: _inputDecoration(
                                        "Enter any remarks..."),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (showBottomSection)
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _submitMultiReturn(
                                dialogContext,
                                date: returnDate,
                                supplierId: supplier?.supplierId,
                                billId: billIdController.text,
                                items: availableItems,
                                qtyControllers: qtyControllers,
                                rateControllers: rateControllers,
                                remarks: remarksController.text,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2a86c9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("SUBMIT",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _tableInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildInputLabelField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF334155))),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _submitMultiReturn(
    BuildContext dialogContext, {
    required DateTime date,
    String? supplierId,
    required String billId,
    required List<PurchaseReturnItem> items,
    required Map<String, TextEditingController> qtyControllers,
    required Map<String, TextEditingController> rateControllers,
    required String remarks,
  }) async {
    List<Map<String, dynamic>> returnItems = [];

    for (var item in items) {
      double qty =
          double.tryParse(qtyControllers[item.itemId]?.text ?? "0") ?? 0;

      if (qty > 0) {
        returnItems.add({
          "material_id": item.materialId,
          "quantity": qty.toString(),
          "unit_price": rateControllers[item.itemId]?.text ?? item.unitPrice,
        });
      }
    }

    if (returnItems.isEmpty) {
      Common.toastMessaage(
          "Please enter return quantity for at least one item", Colors.orange);

      return;
    }

    Common.showProgressDialog(dialogContext, "Submitting...");

    try {
      Map<String, dynamic> data = {
        "return_date": DateFormat('yyyy-MM-dd').format(date),
        "supplier_id": supplierId,
        "bill_id": billId,
        "remarks": remarks,
      };

      for (int i = 0; i < returnItems.length; i++) {
        data["material_id[$i]"] = returnItems[i]["material_id"];

        data["quantity[$i]"] = returnItems[i]["quantity"];

        data["unit_price[$i]"] = returnItems[i]["unit_price"];
      }

      final response = await HttpService.postPurchaseReturn(data);

      Navigator.pop(dialogContext);

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        Common.toastMessaage(
            response['message'] ?? "Return submitted successfully",
            Colors.green);

        Navigator.pop(dialogContext); // Close Add dialog

        _fetchReturns();
      } else {
        Common.toastMessaage(
            response?['message'] ?? "Submission failed", Colors.red);
      }
    } catch (e) {
      if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);

      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  void _showDetailsBottomSheet(PurchaseReturn ret) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ViewPurchaseReturn",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    // Premium Header with Gradient

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
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          const Expanded(
                            child: Text(
                              'Purchase Return Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Content

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.assignment_return,
                                      color: Color(0xFF2a86c9)),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Return ID: #${ret.returnId}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Return Date: ${ret.returnDate}',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Calculated Total Refund Amount Card

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2a86c9),
                                    Color(0xFF1e6399)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Refund Amount",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Calculated Total",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "₹${ret.totalRetAmt}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            _buildDetailSection(
                              "General Information",
                              [
                                _buildModernDetailRow(
                                    Icons.calendar_today_rounded,
                                    "Return Date",
                                    ret.returnDate),
                                _buildModernDetailRow(Icons.business_rounded,
                                    "Supplier", ret.supplierName),
                                _buildModernDetailRow(
                                    Icons.info_outline_rounded,
                                    "Status",
                                    ret.status,
                                    isStatus: true),
                              ],
                            ),

                            const SizedBox(height: 20),

                            _buildDetailSection(
                              "Product Details",
                              [
                                _buildModernDetailRow(Icons.inventory_2_rounded,
                                    "Product", ret.productName),
                                _buildModernDetailRow(
                                    Icons.straighten_rounded,
                                    "Quantity",
                                    "${ret.returnQuantity} ${ret.unitName}"),
                                _buildModernDetailRow(Icons.sell_rounded,
                                    "Unit Price", "₹${ret.unitPrice}"),
                              ],
                            ),

                            const SizedBox(height: 30),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);

                                      _showAddReturnDialog(editReturn: ret);
                                    },
                                    icon: const Icon(Icons.edit_note_rounded),
                                    label: const Text("Edit Return"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      side: BorderSide(
                                          color: Colors.blue.shade200),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);

                                      _deleteReturn(ret.id);
                                    },
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white),
                                    label: const Text("Delete",
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                child: const Text('Close',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey.shade300,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernDetailRow(IconData icon, String label, String value,
      {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey.shade400,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              isStatus
                  ? _buildStatusBadge(value)
                  : Text(value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitReturn(
    BuildContext dialogContext, {
    PurchaseReturn? editReturn,
    required DateTime date,
    String? supplierId,
    String? materialId,
    required String qty,
    required String price,
    required String remarks,
  }) async {
    if (supplierId == null ||
        materialId == null ||
        qty.isEmpty ||
        price.isEmpty) {
      Common.toastMessaage("Please fill all required fields", Colors.orange);

      return;
    }

    Common.showProgressDialog(dialogContext, "Submitting...");

    try {
      Map<String, dynamic> data = {
        "return_date": DateFormat('yyyy-MM-dd').format(date),
        "supplier_id": supplierId,
        "material_id": materialId,
        "quantity": qty,
        "unit_price": price,
        "remarks": remarks,
      };

      if (editReturn != null) {
        data['return_id'] = editReturn.id;
      }

      final response = editReturn != null
          ? await HttpService.updatePurchaseReturn(data)
          : await HttpService.postPurchaseReturn(data);

      Navigator.pop(dialogContext); // Close progress dialog

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        Common.toastMessaage(
            response['message'] ?? "Return submitted successfully",
            Colors.green);

        Navigator.pop(dialogContext); // Close Add dialog

        _fetchReturns();
      } else {
        Common.toastMessaage(
            response?['message'] ?? "Submission failed", Colors.red);
      }
    } catch (e) {
      if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);

      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  Future<void> _deleteReturn(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content:
            const Text("Are you sure you want to delete this purchase return?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Common.showProgressDialog(context, "Deleting...");
      try {
        final response = await HttpService.deletePurchaseReturn(id);
        if (Navigator.canPop(context)) Navigator.pop(context);
        if (response != null &&
            (response['status'] == true || response['status'] == 'success')) {
          Common.toastMessaage("Return deleted successfully", Colors.green);

          _fetchReturns();
        } else {
          Common.toastMessaage(
              response?['message'] ?? "Delete failed", Colors.red);
        }
      } catch (e) {
        if (Navigator.canPop(context)) Navigator.pop(context);

        Common.toastMessaage("Error: $e", Colors.red);
      }
    }
  }

  void _showQuickAddSupplierDialog(BuildContext context,
      {required Function(Supplier) onSupplierAdded}) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController contactPersonCtrl = TextEditingController();
    final TextEditingController contactNoCtrl = TextEditingController();
    final TextEditingController addressCtrl = TextEditingController();
    final TextEditingController aadharCtrl = TextEditingController();
    final TextEditingController gstCtrl = TextEditingController();
    final TextEditingController accountCtrl = TextEditingController();
    final TextEditingController ifscCtrl = TextEditingController();
    final TextEditingController beneficiaryCtrl = TextEditingController();
    final TextEditingController openingBalanceCtrl = TextEditingController();

    List<MaterialData> selectedMaterials = [];
    List<MaterialData> materialsList = [];
    bool isMaterialsLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            if (materialsList.isEmpty && !isMaterialsLoading) {
              isMaterialsLoading = true;
              HttpService.getMaterials().then((val) {
                if (val != null && val.data != null && dialogCtx.mounted) {
                  setDialogState(() {
                    materialsList = val.data!;
                    isMaterialsLoading = false;
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
              bool hasSuffixArrows = false,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (isRequired)
                        const Text(
                          " *",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: isMultiline
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...[
                          Container(
                            width: 42,
                            height: isMultiline ? 80 : 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Icon(prefixIcon,
                                color: const Color(0xFF64748B), size: 18),
                          ),
                        ],
                        Expanded(
                          child: TextField(
                            controller: controller,
                            maxLines: isMultiline ? 3 : 1,
                            keyboardType: keyboardType,
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ),
                        if (hasSuffixArrows) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.keyboard_arrow_up,
                                    size: 14, color: Colors.grey.shade600),
                                Icon(Icons.keyboard_arrow_down,
                                    size: 14, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }

            Widget _buildMaterialDropdown() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Material",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        " *",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownSearch<MaterialData>.multiSelection(
                      items: (f, p) => materialsList,
                      itemAsString: (m) => m.materialName ?? "",
                      compareFn: (i, s) => i.materialId == s.materialId,
                      selectedItems: selectedMaterials,
                      onChanged: (val) => setDialogState(() => selectedMaterials = val),
                      popupProps: PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        onItemAdded: (selectedItems, addedItem) {
                          setDialogState(() {
                            selectedMaterials = selectedItems;
                          });
                        },
                        onItemRemoved: (selectedItems, removedItem) {
                          setDialogState(() {
                            selectedMaterials = selectedItems;
                          });
                        },
                        validationBuilder: (ctx, selectedItems) => const SizedBox.shrink(),
                      ),
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: isMaterialsLoading
                              ? "Loading materials..."
                              : "Choose Material...",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          border: InputBorder.none,
                          suffixIcon: isMaterialsLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(
                            0xFF2a86c9), // Blue color matching your app theme
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ADD SUPPLIER",
                            style: TextStyle(
                              color: Colors.white, // White text
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogCtx),
                            child: const Icon(Icons.close,
                                color: Colors.white,
                                size: 22), // White close icon
                          ),
                        ],
                      ),
                    ),
                    // Scrollable Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMaterialDropdown(),
                            const SizedBox(height: 16),
                            _buildCustomField(
                              label: "Supplier Name",
                              hint: "Enter Supplier Name",
                              controller: nameCtrl,
                              isRequired: true,
                              prefixIcon: Icons.business,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Contact Person",
                                    hint: "Enter Contact Person",
                                    controller: contactPersonCtrl,
                                    prefixIcon: Icons.person,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Contact No",
                                    hint: "Enter Contact No",
                                    controller: contactNoCtrl,
                                    isRequired: true,
                                    prefixIcon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    hasSuffixArrows: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildCustomField(
                              label: "Supplier Address",
                              hint: "Enter Address",
                              controller: addressCtrl,
                              prefixIcon: Icons.location_on,
                              isMultiline: true,
                            ),
                            const SizedBox(height: 16),
                          //  Row(
                             // children: [
                                //Expanded(
                                 // child: 
                                  
                                  _buildCustomField(
                                    label: "Aadhar Number",
                                    hint: "Enter Aadhar Number",
                                    controller: aadharCtrl,
                                    keyboardType: TextInputType.number,
                                    hasSuffixArrows: true,
                                  ),
                               // ),
                                const SizedBox(width: 16),
                                //Expanded(
                                  //child: 
                                  
                                  _buildCustomField(
                                    label: "GST No",
                                    hint: "Enter Gst No",
                                    controller: gstCtrl,
                                  ),
                               // ),
                              //],
                            //),
                            const SizedBox(height: 16),
                           // Row(
                             // children: [
                                //Expanded(
                                 // child: 
                                  
                                  _buildCustomField(
                                    label: "Account Number",
                                    hint: "Enter Account No",
                                    controller: accountCtrl,
                                    keyboardType: TextInputType.number,
                                    hasSuffixArrows: true,
                                  ),
                              //  ),
                                const SizedBox(width: 16),
                               // Expanded(
                                 // child: 
                                  
                                  _buildCustomField(
                                    label: "IFSC Code",
                                    hint: "Enter IFSC Code",
                                    controller: ifscCtrl,
                                  ),
                               // ),
                              //],
                            //),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Beneficiary Name",
                                    hint: "Enter Beneficiary Name",
                                    controller: beneficiaryCtrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Opening Balance",
                                    hint: "Enter Opening Balance",
                                    controller: openingBalanceCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Close",
                              style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              final contactNo = contactNoCtrl.text.trim();

                              if (selectedMaterials.isEmpty) {
                                Common.toastMessaage(
                                    "Please choose a material", Colors.red);
                                return;
                              }
                              if (name.isEmpty) {
                                Common.toastMessaage(
                                    "Please enter supplier name", Colors.red);
                                return;
                              }
                              if (contactNo.isEmpty) {
                                Common.toastMessaage(
                                    "Please enter contact number", Colors.red);
                                return;
                              }
                              if (contactNo.length != 10) {
                                Common.toastMessaage(
                                    "Contact number must be exactly 10 digits", Colors.red);
                                return;
                              }
                              final aadharNo = aadharCtrl.text.trim();
                              if (aadharNo.isNotEmpty && aadharNo.length != 12) {
                                Common.toastMessaage(
                                    "Aadhar number must be exactly 12 digits", Colors.red);
                                return;
                              }

                              showDialog(
                                context: dialogCtx,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                    child: CircularProgressIndicator()),
                              );

                              try {
                                final response = await HttpService.addSupplier({
                                  "material_id": selectedMaterials.map((m) => m.materialId).join(","),
                                 // "material_ids": selectedMaterials.map((m) => m.materialId).toList(),
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
                                });
                                Navigator.pop(dialogCtx); 
                                if (response != null &&
                                    (response['status'] == true ||
                                        response['status'] == 'success')) {
                                  final newSupId =
                                      response['supplier_id']?.toString() ??
                                          response['id']?.toString() ??
                                          DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();

                                  final newSup = Supplier(
                                      supplierId: newSupId, supplierName: name);
                                  onSupplierAdded(newSup);
                                  Navigator.pop(dialogCtx); 
                                  Common.toastMessaage(
                                      "Supplier added successfully",
                                      Colors.green);
                                } else {
                                  Common.toastMessaage(
                                      response?['message'] ??
                                          "Failed to add supplier",
                                      Colors.red);
                                }
                              } catch (e) {
                                Navigator.pop(dialogCtx); 
                                Common.toastMessaage(
                                    "Error adding supplier: $e", Colors.red);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
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
}
