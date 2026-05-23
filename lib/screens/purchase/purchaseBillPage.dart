import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/purchaseBillModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/getSupplierListMode.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/service/service.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login2/models/lead_management/getPurchaseOrderDetailsModel.dart' as order_details_model;

class BillItem {
  MaterialData material;
  double quantity;
  double unitPrice;
  double gstPercentage;
  double cgst;
  double sgst;
  double igst;
  late TextEditingController unitPriceController;
  late TextEditingController gstController;

  BillItem({
    required this.material,
    this.quantity = 1.0,
    this.unitPrice = 0.0,
    this.gstPercentage = 0.0,
    this.cgst = 0.0,
    this.sgst = 0.0,
    this.igst = 0.0,
  }) {
    unitPriceController = TextEditingController(text: unitPrice.toString());
    gstController = TextEditingController(text: gstPercentage.toString());
  }

  double get subTotal => quantity * unitPrice;
  double get gstAmount => subTotal * (gstPercentage / 100);
  double get total => subTotal + gstAmount;

  void dispose() {
    unitPriceController.dispose();
    gstController.dispose();
  }
}

class PaymentItem {
  DateTime paidDate;
  double paidAmount;
  String debitAccount;
  String paymentMode;
  String trRefNo;
  DateTime? trRefDate;
  String remarks;

  PaymentItem({
    required this.paidDate,
    required this.paidAmount,
    required this.debitAccount,
    required this.paymentMode,
    this.trRefNo = "",
    this.trRefDate,
    this.remarks = "",
  });
}

class PurchaseBillPage extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final order_details_model.PurchaseOrderData? createFromOrder;
  final bool showAddDialogOnArrive;

  const PurchaseBillPage({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.createFromOrder,
    this.showAddDialogOnArrive = false,
  });

  @override
  State<PurchaseBillPage> createState() => _PurchaseBillPageState();
}

class _PurchaseBillPageState extends State<PurchaseBillPage> {
  bool isLoading = true;
  List<PurchaseBillData> bills = [];
  List<PurchaseBillData> filteredBills = [];
  String searchQuery = "";

  DateTime? fromDate;
  DateTime? toDate;
  Supplier? selectedSupplier;
  List<Supplier> suppliers = [];

  @override
  void initState() {
    super.initState();
    _fetchBills();
    _fetchSuppliers();
    if (widget.createFromOrder != null || widget.showAddDialogOnArrive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddBillDialog(createFromOrder: widget.createFromOrder);
      });
    }
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

  Future<void> _fetchBills() async {
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

      final response = await HttpService.purchaseBillList(data);
      if (response != null && response.data != null) {
        setState(() {
          bills = response.data!;
          _applySearch();
          isLoading = false;
        });
      } else {
        setState(() {
          bills = [];
          filteredBills = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching purchase bills: $e");
      setState(() => isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      filteredBills = bills.where((bill) {
        final query = searchQuery.toLowerCase();
        return (bill.billNo?.toLowerCase().contains(query) ?? false) ||
            (bill.supplierName?.toLowerCase().contains(query) ?? false);
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
          'Purchase Bills',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBills.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchBills,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          itemCount: filteredBills.length,
                          itemBuilder: (context, index) {
                            return _buildBillCard(filteredBills[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillDialog(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD BILL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter Purchase Bills",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              setSheetState(() => fromDate = picked);
                          },
                          child: _buildFilterBox(
                              "From Date",
                              fromDate != null
                                  ? DateFormat('dd-MM-yyyy').format(fromDate!)
                                  : "Select Date"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              setSheetState(() => toDate = picked);
                          },
                          child: _buildFilterBox(
                              "To Date",
                              toDate != null
                                  ? DateFormat('dd-MM-yyyy').format(toDate!)
                                  : "Select Date"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Supplier",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownSearch<Supplier>(
                      items: (filter, loadProps) => suppliers,
                      itemAsString: (c) => c.supplierName,
                      compareFn: (item, selectedItem) =>
                          item.supplierId == selectedItem?.supplierId,
                      selectedItem: selectedSupplier,
                      onChanged: (val) =>
                          setSheetState(() => selectedSupplier = val),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          border: InputBorder.none,
                          hintText: "Select Supplier",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              fromDate = null;
                              toDate = null;
                              selectedSupplier = null;
                            });
                            Navigator.pop(context);
                            _fetchBills();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchBills();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a86c9),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Apply Filter",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: Color(0xFF2a86c9)),
              const SizedBox(width: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
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
            hintText: 'Search purchase bills...',
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

  Widget _buildBillCard(PurchaseBillData bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: InkWell(
            onTap: () => _showViewDetails(bill),
            child: Row(
              children: [
                Container(
                  width: 6,
                  color: const Color(0xFF2a86c9),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill No: ${bill.billNo ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2a86c9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bill.billDate ?? 'N/A',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Colors.blue, size: 20),
                                  onPressed: () =>
                                      _showAddBillDialog(editBill: bill),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () => _confirmDelete(bill),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bill.supplierName ?? 'Unknown Supplier',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBillDetail(
                                'Sub Total', '₹${bill.itemTotal ?? '0'}'),
                            _buildBillDetail(
                                'GST', '₹${bill.gstAmount ?? '0'}'),
                            _buildBillDetail(
                                'Grand Total', '₹${bill.grandTotal ?? '0'}',
                                isHighlight: true),
                          ],
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
  }

  void _confirmDelete(PurchaseBillData bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Bill"),
        content: Text("Are you sure you want to delete bill ${bill.billNo}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              final res = await HttpService.deletePurchaseBill(bill.billId!);
              if (res != null) {
                Common.toastMessaage("Bill deleted successfully", Colors.green);
                _fetchBills();
              } else {
                setState(() => isLoading = false);
                Common.toastMessaage("Failed to delete bill", Colors.red);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showViewDetails(PurchaseBillData bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Bill Details",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow("Bill No", bill.billNo ?? 'N/A'),
            _buildDetailRow("Bill Date", bill.billDate ?? 'N/A'),
            _buildDetailRow("Supplier", bill.supplierName ?? 'N/A'),
            _buildDetailRow("GST %", bill.gst ?? '0'),
            _buildDetailRow("CGST", bill.cgst ?? '0'),
            _buildDetailRow("SGST", bill.sgst ?? '0'),
            _buildDetailRow("IGST", bill.igst ?? '0'),
            _buildDetailRow("GST Amount", bill.gstAmount ?? '0'),
            _buildDetailRow("Sub Total", bill.itemTotal ?? '0'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2a86c9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Grand Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₹${bill.grandTotal ?? '0'}",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2a86c9))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddBillDialog({
    PurchaseBillData? editBill,
    order_details_model.PurchaseOrderData? createFromOrder,
  }) {
    List<BillItem> cartItems = [];
    List<PaymentItem> paymentItems = [];
    DateTime billDate = DateTime.now();
    DateTime invoiceDate = DateTime.now();
    Supplier? selectedSupplier;
    MaterialData? selectedMaterial;
    PlatformFile? billCopyFile;

    final TextEditingController billIdController = TextEditingController(
        text: editBill?.billNo ??
            "#${DateFormat('HHmm').format(DateTime.now())}");
    final TextEditingController invoiceNoController = TextEditingController();
    final TextEditingController tdsController =
        TextEditingController(text: "0.00");
    final TextEditingController othersController =
        TextEditingController(text: "0.00");
    final TextEditingController discountController =
        TextEditingController(text: "0.00");
    final TextEditingController paidAmtController = TextEditingController();
    final TextEditingController trRefNoController = TextEditingController();
    final TextEditingController remarkController = TextEditingController();

    if (createFromOrder != null) {
      if (createFromOrder.orderDetails != null) {
        final details = createFromOrder.orderDetails!;
        remarkController.text = details.remarks ?? "";
        if (suppliers.any((s) => s.supplierId == details.supplierId)) {
          selectedSupplier = suppliers.firstWhere((s) => s.supplierId == details.supplierId);
        }
      }
      if (createFromOrder.items != null) {
        cartItems = createFromOrder.items!.map((item) {
          return BillItem(
            material: MaterialData(
              materialId: item.materialId,
              materialName: item.materialName,
              unitName: item.unitName,
            ),
            quantity: double.tryParse(item.quantity ?? "1") ?? 1.0,
            unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,
            gstPercentage: 0.0,
          );
        }).toList();
      }
    }

    bool deductFromAdvance = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "AddPurchaseBill",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        List<MaterialData> dialogMaterials = [];
        List<ListElement> accountHeads = [];
        bool isFetching = false;
        bool isFetchingAccounts = false;
        bool isDetailsFetched = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            if (createFromOrder != null && selectedSupplier == null && suppliers.isNotEmpty) {
              final details = createFromOrder.orderDetails;
              if (details != null && suppliers.any((s) => s.supplierId == details.supplierId)) {
                selectedSupplier = suppliers.firstWhere((s) => s.supplierId == details.supplierId);
              }
            }
            if (dialogMaterials.isEmpty && !isFetching) {
              isFetching = true;
              HttpService.getMaterials().then((val) {
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    dialogMaterials = val.data!;
                    isFetching = false;
                  });
                }
              });
            }

            if (accountHeads.isEmpty && !isFetchingAccounts) {
              isFetchingAccounts = true;
              HttpService.getAccountHead().then((val) {
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    accountHeads = val.data!.lists;
                    isFetchingAccounts = false;
                  });
                }
              });
            }

            if (editBill != null && !isDetailsFetched) {
              isDetailsFetched = true;
              HttpService.getPurchaseBillDetailsEdit(editBill.id!).then((val) {
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    final d = val.data!;
                    if (d.billDetails != null) {
                      billIdController.text = d.billDetails!.billId ?? "";
                      try {
                        billDate = DateFormat('dd-MM-yyyy')
                            .parse(d.billDetails!.billDate ?? "");
                      } catch (e) {
                        billDate = DateTime.now();
                      }
                      if (suppliers.any(
                          (s) => s.supplierId == d.billDetails!.supplierId)) {
                        selectedSupplier = suppliers.firstWhere(
                            (s) => s.supplierId == d.billDetails!.supplierId);
                      }
                    }
                    if (d.items != null) {
                      cartItems = d.items!
                          .map((item) => BillItem(
                                material: MaterialData(
                                    materialId: item.materialId,
                                    materialName: item.materialName,
                                    unitName: item.unitName,
                                    unitPrice: item.unitPrice,
                                    gstPercentage: item.gst),
                                quantity:
                                    double.tryParse(item.quantity ?? "1") ??
                                        1.0,
                                unitPrice:
                                    double.tryParse(item.unitPrice ?? "0") ??
                                        0.0,
                                gstPercentage:
                                    double.tryParse(item.gst ?? "0") ?? 0.0,
                              ))
                          .toList();
                    }
                  });
                }
              });
            }

            double totalSubtotal =
                cartItems.fold(0, (sum, item) => sum + item.subTotal);
            double totalGst =
                cartItems.fold(0, (sum, item) => sum + item.gstAmount);
            double tds = double.tryParse(tdsController.text) ?? 0.0;
            double others = double.tryParse(othersController.text) ?? 0.0;
            double discount = double.tryParse(discountController.text) ?? 0.0;
            double payableAmount =
                totalSubtotal + totalGst + tds + others - discount;
            double totalPaid =
                paymentItems.fold(0.0, (sum, p) => sum + p.paidAmount);
            double balanceAmount = payableAmount - totalPaid;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          color: const Color(0xFF2a86c9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  editBill == null
                                      ? "Purchase Bill"
                                      : "Edit Purchase Bill",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context)),
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
                                    editBill != null?
                                    Expanded(
                                        child: _buildInputLabelField(
                                            label: "Bill Id",
                                            child: TextField(
                                                controller: billIdController,
                                                decoration:
                                                    _inputDecoration("Bill Id"),
                                                readOnly: true))):SizedBox(),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Bill Date*",
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                                context: context,
                                                initialDate: billDate,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100));
                                            if (picked != null)
                                              setDialogState(
                                                  () => billDate = picked);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300)),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Text(DateFormat('dd-MM-yyyy')
                                                    .format(billDate)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildInputLabelField(
                                        label: "Supplier Name*",
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300)),
                                          child: DropdownSearch<Supplier>(
                                            items: (filter, loadProps) =>
                                                suppliers,
                                            itemAsString: (s) => s.supplierName,
                                            compareFn: (item, selectedItem) =>
                                                item?.supplierId ==
                                                selectedItem?.supplierId,
                                            selectedItem: selectedSupplier,
                                            onChanged: (val) => setDialogState(
                                                () => selectedSupplier = val),
                                            decoratorProps:
                                                const DropDownDecoratorProps(
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                  border: InputBorder.none,
                                                  hintText: "Select Supplier"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    editBill != null?
                                    const SizedBox(width: 12):SizedBox(),
                                    editBill != null?
                                    Expanded(
                                        child: _buildInputLabelField(
                                            label: "Invoice Number",
                                            child: TextField(
                                                controller: invoiceNoController,
                                                decoration: _inputDecoration(
                                                    "Invoice Number")))):SizedBox(),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabelField(
                                  label: "Invoice Date",
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                          context: context,
                                          initialDate: invoiceDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100));
                                      if (picked != null)
                                        setDialogState(
                                            () => invoiceDate = picked);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(DateFormat('dd-MM-yyyy')
                                              .format(invoiceDate)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text("ADD ITEMS TO CART",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.blueGrey)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Product",
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300)),
                                          child: DropdownSearch<MaterialData>(
                                            items: (filter, loadProps) =>
                                                dialogMaterials,
                                            itemAsString: (m) =>
                                                m.materialName ?? "",
                                            compareFn: (item, selectedItem) =>
                                                item.materialId ==
                                                selectedItem?.materialId,
                                            onChanged: (val) => setDialogState(
                                                () => selectedMaterial = val),
                                            decoratorProps:
                                                const DropDownDecoratorProps(
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                  border: InputBorder.none,
                                                  hintText: "Select"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (selectedMaterial != null) {
                                            setDialogState(() {
                                              cartItems.add(BillItem(
                                                material: selectedMaterial!,
                                                unitPrice: double.tryParse(
                                                        selectedMaterial!
                                                                .unitPrice ??
                                                            "0") ??
                                                    0.0,
                                                gstPercentage: double.tryParse(
                                                        selectedMaterial!
                                                                .gstPercentage ??
                                                            "0") ??
                                                    0.0,
                                              ));
                                              selectedMaterial = null;
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.add,
                                            color: Colors.white, size: 18),
                                        label: const Text("Add to cart",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2a86c9),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowColor: WidgetStateProperty.all(
                                        Colors.grey.shade100),
                                    columns: const [
                                      DataColumn(label: Text("#")),
                                      DataColumn(label: Text("Material")),
                                      DataColumn(label: Text("Unit")),
                                      DataColumn(label: Text("Quantity")),
                                      DataColumn(label: Text("Unit Price")),
                                      DataColumn(label: Text("Sub Total")),
                                      DataColumn(label: Text("GST %")),
                                      DataColumn(label: Text("CGST")),
                                      DataColumn(label: Text("SGST")),
                                      DataColumn(label: Text("IGST")),
                                      DataColumn(label: Text("GST Amt")),
                                      DataColumn(label: Text("Action")),
                                    ],
                                    rows: List.generate(cartItems.length,
                                        (index) {
                                      final item = cartItems[index];
                                      return DataRow(cells: [
                                        DataCell(Text("${index + 1}")),
                                        DataCell(Text(
                                            item.material.materialName ?? "")),
                                        DataCell(
                                            Text(item.material.unitName ?? "")),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                    size: 18,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  if (item.quantity > 1) {
                                                    setDialogState(
                                                        () => item.quantity--);
                                                  }
                                                },
                                              ),
                                              Text(
                                                  item.quantity
                                                      .toInt()
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    size: 18,
                                                    color: Colors.green),
                                                onPressed: () {
                                                  setDialogState(
                                                      () => item.quantity++);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(SizedBox(
                                            width: 80,
                                            child: TextField(
                                                controller:
                                                    item.unitPriceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (v) =>
                                                    setDialogState(() => item
                                                            .unitPrice =
                                                        double.tryParse(v) ??
                                                            0.0),
                                                decoration: const InputDecoration(
                                                    isDense: true,
                                                    border:
                                                        OutlineInputBorder())))),
                                        DataCell(Text(
                                            item.subTotal.toStringAsFixed(2))),
                                        DataCell(SizedBox(
                                            width: 60,
                                            child: TextField(
                                                controller: item.gstController,
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (v) =>
                                                    setDialogState(() => item
                                                            .gstPercentage =
                                                        double.tryParse(v) ??
                                                            0.0),
                                                decoration: const InputDecoration(
                                                    isDense: true,
                                                    border:
                                                        OutlineInputBorder())))),
                                        DataCell(Text(
                                            (item.gstPercentage / 2)
                                                .toStringAsFixed(2),
                                            style:
                                                const TextStyle(fontSize: 12))),
                                        DataCell(Text(
                                            (item.gstPercentage / 2)
                                                .toStringAsFixed(2),
                                            style:
                                                const TextStyle(fontSize: 12))),
                                        DataCell(const Text("0.00",
                                            style: TextStyle(fontSize: 12))),
                                        DataCell(Text(
                                            item.gstAmount.toStringAsFixed(2))),
                                        DataCell(IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 18),
                                          onPressed: () async {
                                            // For edit mode with existing bill, call API
                                            if (editBill != null &&
                                                editBill.billId != null) {
                                              bool? confirm = await showDialog(
                                                context: dialogContext,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Delete Product'),
                                                  content: Text(
                                                      'Delete "${item.material.materialName}" from this bill?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      style:
                                                          TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.red),
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                showDialog(
                                                  context: dialogContext,
                                                  barrierDismissible: false,
                                                  builder: (context) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                );
                                                final response = await HttpService
                                                    .deletePurchaseOrderBillProduct(
                                                  productId:
                                                      item.material.materialId!,
                                                  billId: editBill.id!,
                                                );
                                                Navigator.pop(
                                                    dialogContext); 
                                                if (response?.status == true) {
                                                  Common.toastMessaage(
                                                      'Product deleted successfully',
                                                      Colors.green);
                                                  setDialogState(() {
                                                    item.dispose();
                                                    cartItems.removeAt(index);
                                                  });
                                                  if (editBill.id != null) {
                                                    final refreshData =
                                                        await HttpService
                                                            .getPurchaseBillDetailsEdit(
                                                                editBill.id!);
                                                    if (refreshData
                                                                ?.data?.items !=
                                                            null &&
                                                        dialogContext.mounted) {
                                                      setDialogState(() {
                                                        cartItems.clear();
                                                        cartItems.addAll(
                                                            refreshData!
                                                                .data!.items!
                                                                .map((item) =>
                                                                    BillItem(
                                                                      material:
                                                                          MaterialData(
                                                                        materialId:
                                                                            item.materialId,
                                                                        materialName:
                                                                            item.materialName,
                                                                        unitName:
                                                                            item.unitName,
                                                                        unitPrice:
                                                                            item.unitPrice,
                                                                        gstPercentage:
                                                                            item.gst,
                                                                      ),
                                                                      quantity:
                                                                          double.tryParse(item.quantity ?? "1") ??
                                                                              1.0,
                                                                      unitPrice:
                                                                          double.tryParse(item.unitPrice ?? "0") ??
                                                                              0.0,
                                                                      gstPercentage:
                                                                          double.tryParse(item.gst ?? "0") ??
                                                                              0.0,
                                                                    ))
                                                                .toList());
                                                      });
                                                    }
                                                  }
                                                } else {
                                                  Common.toastMessaage(
                                                      response?.message ??
                                                          'Delete failed',
                                                      Colors.red);
                                                }
                                              }
                                            } else {
                                              // For new bill, just remove from cart without API call
                                              setDialogState(() {
                                                item.dispose();
                                                cartItems.removeAt(index);
                                              });
                                            }
                                          },
                                        )),
                                        //                       DataCell(IconButton(
                                        //                           icon: const Icon(Icons.delete,
                                        //                               color: Colors.red, size: 18),
                                        //                           onPressed: () async {

                                        //                             setDialogState(() {
                                        //                               item.dispose();
                                        //                               cartItems.removeAt(index);
                                        //                             });
                                        //                                 bool? confirm = await showDialog(
                                        //   context: dialogContext,
                                        //   builder: (context) => AlertDialog(
                                        //     title: const Text('Delete Product'),
                                        //     content: Text('Delete "${item.material.materialName}"?'),
                                        //     actions: [
                                        //       TextButton(
                                        //         onPressed: () => Navigator.pop(context, false),
                                        //         child: const Text('Cancel'),
                                        //       ),
                                        //       TextButton(
                                        //         onPressed: () => Navigator.pop(context, true),
                                        //         style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        //         child: const Text('Delete'),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // );

                                        // if (confirm == true) {
                                        //   // Show loading
                                        //   showDialog(
                                        //     context: dialogContext,
                                        //     barrierDismissible: false,
                                        //     builder: (context) => const Center(child: CircularProgressIndicator()),
                                        //   );

                                        //   // Call API
                                        //   final response = await HttpService.deletePurchaseOrderBillProduct(
                                        //     productId: item.material.materialId!,
                                        //     billId: item.billId!, // Assuming you have a billId property
                                        //   );

                                        //   Navigator.pop(dialogContext); // Close loading

                                        //   if (response?.status == true) {
                                        //     Common.toastMessaage('Product deleted', Colors.green);
                                        //  //  onDelete(); // Remove from cart
                                        //   } else {
                                        //     Common.toastMessaage(response?.message ?? 'Delete failed', Colors.red);
                                        //   }
                                        // }
                                        //                           })),
                                      ]);
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.grey.shade50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text("Total Subtotal: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.grey.shade300)),
                                        child: Text(
                                            totalSubtotal.toStringAsFixed(2)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _buildFinancialRow("TDS", tdsController,
                                            setDialogState),
                                        _buildFinancialRow("OTHERS",
                                            othersController, setDialogState),
                                        _buildFinancialRow("DISCOUNT",
                                            discountController, setDialogState),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                const SizedBox(height: 30),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Payment Details",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      ElevatedButton.icon(
                                        onPressed: () => _showAddPaymentPopup(
                                            context, accountHeads,
                                            (PaymentItem newItem) {
                                          setDialogState(() {
                                            paymentItems.add(newItem);
                                          });
                                        }),
                                        icon: const Icon(Icons.add,
                                            size: 16, color: Colors.white),
                                        label: const Text("Add Payment",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2a86c9),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowHeight: 40,
                                    dataRowHeight: 50,
                                    headingRowColor: WidgetStateProperty.all(
                                        Colors.grey.shade100),
                                    columns: const [
                                      DataColumn(label: Text("#")),
                                      DataColumn(label: Text("Paid Date")),
                                      DataColumn(label: Text("Paid Amount")),
                                      DataColumn(label: Text("Debit Acc")),
                                      DataColumn(label: Text("Payment Mode")),
                                      DataColumn(label: Text("TR Ref No")),
                                      DataColumn(label: Text("TR Ref Date")),
                                      DataColumn(label: Text("Remarks")),
                                      DataColumn(label: Text("Action")),
                                    ],
                                    rows: List.generate(paymentItems.length,
                                        (index) {
                                      final p = paymentItems[index];
                                      return DataRow(cells: [
                                        DataCell(Text("${index + 1}")),
                                        DataCell(Text(DateFormat('dd-MM-yyyy')
                                            .format(p.paidDate))),
                                        DataCell(Text(
                                            p.paidAmount.toStringAsFixed(2))),
                                        DataCell(Text(p.debitAccount)),
                                        DataCell(Text(p.paymentMode)),
                                        DataCell(Text(p.trRefNo)),
                                        DataCell(Text(p.trRefDate != null
                                            ? DateFormat('dd-MM-yyyy')
                                                .format(p.trRefDate!)
                                            : "-")),
                                        DataCell(Text(p.remarks)),
                                        DataCell(IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 16),
                                          onPressed: () {
                                            setDialogState(() {
                                              paymentItems.removeAt(index);
                                            });
                                          },
                                        )),
                                      ]);
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Table(
                                  border: TableBorder.all(
                                      color: Colors.grey.shade300),
                                  children: [
                                    TableRow(
                                      // backgroundColor: Colors.grey.shade100,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text("PAYABLE AMOUNT",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text("TOTAL PAID",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text("BALANCE AMOUNT",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)))),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text(payableAmount
                                                    .toStringAsFixed(2)))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text(
                                                    "₹${totalPaid.toStringAsFixed(2)}"))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text(balanceAmount
                                                    .toStringAsFixed(2)))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                _buildInputLabelField(
                                  label: "Upload Bill Copy",
                                  child: InkWell(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles();
                                      if (result != null) {
                                        setDialogState(() =>
                                            billCopyFile = result.files.first);
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey.shade300)),
                                      child: Row(
                                        children: [
                                          Icon(Icons.upload_file,
                                              size: 16,
                                              color: billCopyFile != null
                                                  ? Colors.blue
                                                  : Colors.grey),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              billCopyFile != null
                                                  ? billCopyFile!.name
                                                  : "No file selected.",
                                              style: TextStyle(
                                                  color: billCopyFile != null
                                                      ? Colors.black
                                                      : Colors.grey,
                                                  fontSize: 13,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabelField(
                                    label: "Transaction Remark",
                                    child: TextField(
                                        controller: remarkController,
                                        maxLines: 2,
                                        decoration:
                                            _inputDecoration("Remarks/Notes"))),
                                const SizedBox(height: 40),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (selectedSupplier == null ||
                                          cartItems.isEmpty) {
                                        Common.toastMessaage(
                                            "Please fill required fields and add items",
                                            Colors.orange);
                                        return;
                                      }
                                      setDialogState(() => isLoading = true);
                                      Map<String, dynamic> body = {
                                        "bill_no": billIdController.text,
                                        "bill_date": DateFormat('yyyy-MM-dd')
                                            .format(billDate),
                                        "supplier_id":
                                            selectedSupplier!.supplierId,
                                        "invoice_no": invoiceNoController.text,
                                        "invoice_date": DateFormat('yyyy-MM-dd')
                                            .format(invoiceDate),
                                        "sub_total": totalSubtotal,
                                        "gst_amount": totalGst,
                                        "grand_total": payableAmount,
                                        "paid_amount": totalPaid,
                                        "balance_amount": balanceAmount,
                                        "tds": tdsController.text,
                                        "others": othersController.text,
                                        "discount": discountController.text,
                                        "bill_no": billIdController.text,
                                        "item_total":
                                            totalSubtotal.toStringAsFixed(2),
                                        "gst_total":
                                            totalGst.toStringAsFixed(2),
                                        "tds_amount": tds.toStringAsFixed(2),
                                        "other_charges":
                                            others.toStringAsFixed(2),
                                        "discount_amount":
                                            discount.toStringAsFixed(2),
                                        "grand_total":
                                            payableAmount.toStringAsFixed(2),
                                        "remarks": remarkController.text,
                                      };

                                      if (editBill != null) {
                                        body["bill_id"] = editBill.billId;
                                      }

                                      if (billCopyFile != null) {
                                        body["bill_copy"] =
                                            await dio.MultipartFile.fromFile(
                                                billCopyFile!.path!);
                                      }

                                      for (int i = 0;
                                          i < cartItems.length;
                                          i++) {
                                        body["material_id[$i]"] =
                                            cartItems[i].material.materialId;
                                        body["quantity[$i]"] =
                                            cartItems[i].quantity;
                                        body["unit_price[$i]"] =
                                            cartItems[i].unitPrice;
                                        body["gst_percentage[$i]"] =
                                            cartItems[i].gstPercentage;
                                      }

                                      for (int i = 0;
                                          i < paymentItems.length;
                                          i++) {
                                        body["paid_date[$i]"] =
                                            DateFormat('yyyy-MM-dd').format(
                                                paymentItems[i].paidDate);
                                        body["paid_amount[$i]"] =
                                            paymentItems[i].paidAmount;
                                        body["debit_account[$i]"] =
                                            paymentItems[i].debitAccount;
                                        body["payment_mode[$i]"] =
                                            paymentItems[i].paymentMode;
                                        body["tr_ref_no[$i]"] =
                                            paymentItems[i].trRefNo;
                                        if (paymentItems[i].trRefDate != null) {
                                          body["tr_ref_date[$i]"] =
                                              DateFormat('yyyy-MM-dd').format(
                                                  paymentItems[i].trRefDate!);
                                        }
                                        body["payment_remarks[$i]"] =
                                            paymentItems[i].remarks;
                                      }

                                      final res = editBill == null
                                          ? await HttpService.postPurchaseBill(
                                              body)
                                          : await HttpService
                                              .updatePurchaseBill(body);
                                      if (res != null) {
                                        Common.toastMessaage(
                                            "Bill saved successfully",
                                            Colors.green);
                                        Navigator.pop(context);
                                        _fetchBills();
                                      } else {
                                        setDialogState(() => isLoading = false);
                                        Common.toastMessaage(
                                            "Failed to save bill", Colors.red);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: const Text("SUBMIT",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
      },
    );
  }

  Widget _buildFinancialRow(String label, TextEditingController controller,
      StateSetter setDialogState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300)),
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300)),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (v) => setDialogState(() {}),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  border: InputBorder.none, prefixText: "₹"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300)),
      child: Text(text, style: const TextStyle(color: Colors.black54)),
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
                color: Colors.blueGrey)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildBillDetail(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlight ? 14 : 12,
            color: isHighlight ? Colors.green.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showAddPaymentPopup(BuildContext context, List<ListElement> accounts,
      Function(PaymentItem) onAdd) {
    DateTime paidDate = DateTime.now();
    DateTime? trRefDate = DateTime.now();
    String paymentMode = "Cash";
    ListElement? selectedAccount;
    final TextEditingController amountController = TextEditingController();
    final TextEditingController trRefNoController = TextEditingController();
    final TextEditingController remarksController = TextEditingController();
    Supplier? selectedSupplierPopup;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2a86c9),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Add Transaction",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabelField(
                          label: "Supplier Name*",
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey.shade300)),
                            child: DropdownSearch<Supplier>(
                              items: (f, p) => suppliers,
                              itemAsString: (s) => s.supplierName ?? "",
                              compareFn: (item, selectedItem) =>
                                  item.supplierId == selectedItem?.supplierId,
                              onChanged: (val) =>
                                  setState(() => selectedSupplierPopup = val),
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  border: InputBorder.none,
                                  hintText: "Select Supplier",
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputLabelField(
                          label: "Paid Amount*",
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("₹ 0.00"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                      context: context,
                                      initialDate: paidDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100));
                                  if (picked != null)
                                    setState(() => paidDate = picked);
                                },
                                child: _buildInputLabelField(
                                  label: "Paid Date*",
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade300)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(DateFormat('dd-MM-yyyy')
                                            .format(paidDate)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInputLabelField(
                                label: "Paid From Account",
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  child: DropdownSearch<ListElement>(
                                    items: (f, p) => accounts,
                                    itemAsString: (a) => a.accountName,
                                    compareFn: (item, selectedItem) =>
                                        item.accountId ==
                                        selectedItem?.accountId,
                                    onChanged: (val) =>
                                        setState(() => selectedAccount = val),
                                    decoratorProps:
                                        const DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        border: InputBorder.none,
                                        hintText: "Select Account",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputLabelField(
                                label: "Payment Mode*",
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: paymentMode,
                                      isExpanded: true,
                                      items: [
                                        "Cash",
                                        "Bank",
                                        "Cheque",
                                        "Online"
                                      ]
                                          .map((e) => DropdownMenuItem(
                                              value: e, child: Text(e)))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => paymentMode = v!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInputLabelField(
                                label: "TR Reference No",
                                child: TextField(
                                  controller: trRefNoController,
                                  decoration: _inputDecoration("TR #"),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: trRefDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              setState(() => trRefDate = picked);
                          },
                          child: _buildInputLabelField(
                            label: "TR Reference Date",
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(trRefDate != null
                                      ? DateFormat('dd-MM-yyyy')
                                          .format(trRefDate!)
                                      : "Select Date"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputLabelField(
                          label: "Transaction Remark",
                          child: TextField(
                            controller: remarksController,
                            maxLines: 2,
                            decoration: _inputDecoration("Enter remark..."),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Close"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.isNotEmpty) {
                            onAdd(PaymentItem(
                              paidDate: paidDate,
                              paidAmount:
                                  double.tryParse(amountController.text) ?? 0.0,
                              debitAccount:
                                  selectedAccount?.accountName ?? "N/A",
                              paymentMode: paymentMode,
                              trRefNo: trRefNoController.text,
                              trRefDate: trRefDate,
                              remarks: remarksController.text,
                            ));
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Submit",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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

  // Widget _buildReadOnlyField(String value) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Bills Found',
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
}
