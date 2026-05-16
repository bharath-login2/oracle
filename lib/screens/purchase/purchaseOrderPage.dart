import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getPurchseOrderModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/getSupplierListMode.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/models/lead_management/getPurchaseOrderDetailsModel.dart'
    as details;
import 'package:login2/service/service.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class PurchaseOrderPage extends StatefulWidget {
  final String token;
  final String name;
  final String userId;

  const PurchaseOrderPage({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
  });

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  bool isLoading = true;
  List<PurchaseOrderData> orders = [];
  List<PurchaseOrderData> filteredOrders = [];
  String searchQuery = "";

  DateTime? fromDate;
  DateTime? toDate;
  String selectedStatus = "All";
  Supplier? selectedSupplierFilter;
  List<Supplier> suppliers = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchSuppliers();
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

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> data = {};
      if (selectedSupplierFilter != null) {
        data['supplier_id'] = selectedSupplierFilter!.supplierId;
      }
      final response = await HttpService.purchaseOrderList(data);
      if (response != null && response.data != null) {
        setState(() {
          orders = response.data!;
          _applySearch();
          isLoading = false;
        });
      } else {
        setState(() {
          orders = [];
          filteredOrders = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching purchase orders: $e");
      setState(() => isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      filteredOrders = orders.where((order) {
        final query = searchQuery.toLowerCase();
        bool matchesSearch =
            (order.orderId?.toLowerCase().contains(query) ?? false) ||
                (order.supplierName?.toLowerCase().contains(query) ?? false) ||
                (order.billStatus?.toLowerCase().contains(query) ?? false);

        bool matchesStatus = selectedStatus == "All" ||
            (order.billStatus?.toLowerCase() == selectedStatus.toLowerCase());

        bool matchesDate = true;
        if (fromDate != null || toDate != null) {
          try {
            DateTime orderDT = DateFormat("dd-MM-yyyy").parse(order.orderDate!);
            if (fromDate != null && orderDT.isBefore(fromDate!))
              matchesDate = false;
            if (toDate != null &&
                orderDT.isAfter(toDate!.add(const Duration(days: 1))))
              matchesDate = false;
          } catch (e) {}
        }

        return matchesSearch && matchesStatus && matchesDate;
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
          'Purchase Orders',
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
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(filteredOrders[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderDialog(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW ORDER',
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
            hintText: 'Search purchase orders...',
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

  Widget _buildOrderCard(PurchaseOrderData order) {
    bool isBilled = order.billStatus?.toLowerCase() == 'billed';

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
              onTap: () => _showViewDrawer(order),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    color: isBilled ? Colors.green : Colors.orange,
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
                              Text(
                                'Order NO: #${order.orderId ?? 'N/A'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStatusBadge(
                                      order.billStatus ?? 'Pending'),
                                  if (!isBilled) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.blue, size: 20),
                                      onPressed: () =>
                                          _fetchOrderDetailsAndShowDialog(
                                              order),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.business,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.supplierName ?? 'Unknown Supplier',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                order.orderDate ?? 'N/A',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAmountColumn(
                                  'Estimated',
                                  '₹${order.estimatedAmt ?? '0'}',
                                  Colors.black87),
                              _buildAmountColumn('Advance',
                                  '₹${order.advanceAmt ?? '0'}', Colors.green),
                              _buildAmountColumn(
                                  'Balance',
                                  '₹${order.balanceAmt ?? '0'}',
                                  Colors.redAccent),
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
        ));
  }

  Widget _buildAmountColumn(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isBilled = status.toLowerCase().contains('bill');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isBilled
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isBilled ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _fetchOrderDetailsAndShowDialog(PurchaseOrderData order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response =
          await HttpService.getPurchaseOrderDetails(order.poId!);
      Navigator.pop(context); 
      if (response != null && response.status == true && response.data != null) {
        _showOrderDialog(editData: response.data);
      } else {
        Common.toastMessaage(
            response?.message ?? "Failed to fetch order details", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      Common.toastMessaage("Error fetching details: $e", Colors.red);
    }
  }



  void _showOrderDialog({details.PurchaseOrderData? editData}) {
  List<CartItem> cartItems = [];
  DateTime orderDate = DateTime.now();
  DateTime? paidDate = DateTime.now();
  DateTime? deliveryDate;
  DateTime? trRefDate = DateTime.now();

  MaterialData? selectedMaterial;
  Supplier? selectedSupplier;
  String? selectedAccount;
  String? paymentMode = "Cash";
  PlatformFile? orderCopyFile;

  final TextEditingController refNoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController advancePaidController = TextEditingController();
  final TextEditingController trRefNoController = TextEditingController();
  final TextEditingController transRemarkController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  if (editData != null && editData.orderDetails != null) {
    var d = editData.orderDetails!;
    try {
      orderDate = DateFormat('yyyy-MM-dd').parse(d.orderDate!);
    } catch (e) {}
    selectedSupplier = suppliers.any((s) => s.supplierId == d.supplierId)
        ? suppliers.firstWhere((s) => s.supplierId == d.supplierId)
        : null;
    paymentMode = d.paymentMethod ?? "Cash";
    advancePaidController.text = d.advanceAmount ?? "";
    refNoController.text = d.referenceNo ?? d.refNo ?? "";
    addressController.text = d.billingAddress ?? d.address ?? "";
    remarksController.text = d.remarks ?? "";
    if (d.deliveryDate != null && d.deliveryDate!.isNotEmpty) {
      try {
        deliveryDate = DateFormat('yyyy-MM-dd').parse(d.deliveryDate!);
      } catch (e) {}
    }
  }

  if (editData != null && editData.items != null) {
    cartItems = editData.items!.map((item) {
      return CartItem(
        material: MaterialData(
          materialId: item.materialId,
          materialName: item.materialName,
          unitPrice: item.unitPrice,
        ),
        quantity: double.tryParse(item.quantity ?? "1") ?? 1.0,
        unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,
      );
    }).toList();
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "AddPurchaseOrder",
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
    pageBuilder: (context, anim1, anim2) {
      List<MaterialData> dialogMaterials = [];
      List<ListElement> accountHeads = [];
      bool isFetching = false;
      bool isFetchingAccounts = false;

      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
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

          double totalAmount =
              cartItems.fold(0, (sum, item) => sum + item.total);

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2a86c9), Color(0xFF1e6399)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.shopping_cart_checkout,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                editData == null
                                    ? "Purchase Order"
                                    : "Edit Purchase Order",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 26),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                  "Order Details", Icons.assignment_outlined),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildGlassCard(
                                      title: "Order No",
                                      value:
                                          "#${DateFormat('HHmmss').format(DateTime.now())}",
                                      icon: Icons.tag,
                                      color: const Color(0xFF2a86c9),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: orderDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null)
                                          setDialogState(
                                              () => orderDate = picked);
                                      },
                                      child: _buildGlassCard(
                                        title: "Order Date",
                                        value: DateFormat('dd-MM-yyyy')
                                            .format(orderDate),
                                        icon: Icons.calendar_today,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
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
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: DropdownSearch<Supplier>(
                                          compareFn: (item, selectedItem) =>
                                              item.supplierId ==
                                              selectedItem?.supplierId,
                                          selectedItem: selectedSupplier,
                                          items: (f, p) => suppliers,
                                          itemAsString: (s) => s.supplierName,
                                          decoratorProps:
                                              const DropDownDecoratorProps(
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              border: InputBorder.none,
                                              hintText: "Select Supplier",
                                            ),
                                          ),
                                          onChanged: (val) => setDialogState(
                                              () => selectedSupplier = val),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Reference No",
                                      child: TextField(
                                        controller: refNoController,
                                        decoration: _inputDecoration("Ref #"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInputLabelField(
                                label: "Billing Address*",
                                child: TextField(
                                  controller: addressController,
                                  maxLines: 2,
                                  decoration: _inputDecoration(
                                      "Enter full billing address..."),
                                ),
                              ),
                              const Divider(height: 40),
                              _buildSectionHeader("Add Items to Cart",
                                  Icons.add_shopping_cart_rounded),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5))
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    DropdownSearch<MaterialData>(
                                      compareFn: (i, s) =>
                                          i?.materialId == s?.materialId,
                                      items: (f, p) => dialogMaterials
                                          .where((m) =>
                                              m.materialName
                                                  ?.toLowerCase()
                                                  .contains(
                                                      f.toLowerCase()) ??
                                              true)
                                          .toList(),
                                      itemAsString: (m) =>
                                          m.materialName ?? "",
                                      decoratorProps:
                                          const DropDownDecoratorProps(
                                        decoration: InputDecoration(
                                          hintText: "Search material",
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          prefixIcon: Icon(
                                              Icons.inventory_2_outlined),
                                        ),
                                      ),
                                      popupProps: const PopupProps.menu(
                                          showSearchBox: true),
                                      onChanged: (val) => setDialogState(
                                          () => selectedMaterial = val),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (selectedMaterial != null) {
                                            setDialogState(() {
                                              cartItems.add(CartItem(
                                                material: selectedMaterial!,
                                                unitPrice: double.tryParse(
                                                        selectedMaterial!
                                                                .unitPrice ??
                                                            "0") ??
                                                    0.0,
                                              ));
                                              selectedMaterial = null;
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.add,
                                            color: Colors.white),
                                        label: const Text("ADD TO CART",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2a86c9),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Cart Items",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF2a86c9)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text("${cartItems.length} Items",
                                        style: const TextStyle(
                                            color: Color(0xFF2a86c9),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              cartItems.isEmpty
                                  ? _buildEmptyCart()
                                  : Column(
                                      children: List.generate(
                                          cartItems.length, (index) {
                                        return _buildCartItemCard(
                                          cartItems[index],
                                          index,
                                          setDialogState,
                                          () {
                                            setDialogState(() {
                                              cartItems[index].dispose();
                                              cartItems.removeAt(index);
                                            });
                                          },
                                          editData, // Pass editData
                                          dialogContext, // Pass dialogContext
                                        );
                                      }),
                                    ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total Estimated Amount",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("₹${totalAmount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Color(0xFF2a86c9),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ],
                                ),
                              ),
                              const Divider(height: 40),
                              _buildSectionHeader(
                                  "Payment Details", Icons.payments_outlined),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Advance Paid",
                                      child: TextField(
                                        controller: advancePaidController,
                                        keyboardType: TextInputType.number,
                                        decoration:
                                            _inputDecoration("₹ 0.00"),
                                      ),
                                    ),
                                  ),
                                  if (editData == null) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  paidDate ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100));
                                          if (picked != null)
                                            setDialogState(
                                                () => paidDate = picked);
                                        },
                                        child: _buildInputLabelField(
                                          label: "Paid Date",
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 16,
                                                    color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Text(
                                                    paidDate != null
                                                        ? DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(paidDate!)
                                                        : "Select Date",
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (editData == null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Paid From Account",
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200)),
                                          child: DropdownSearch<ListElement>(
                                            compareFn: (i, s) =>
                                                i.accountId == s?.accountId,
                                            selectedItem: accountHeads.any((a) =>
                                                    a.accountName ==
                                                    selectedAccount)
                                                ? accountHeads.firstWhere((a) =>
                                                    a.accountName ==
                                                    selectedAccount)
                                                : null,
                                            items: (f, p) => accountHeads
                                                .where((a) => a.accountName
                                                    .toLowerCase()
                                                    .contains(f.toLowerCase()))
                                                .toList(),
                                            itemAsString: (a) => a.accountName,
                                            onChanged: (val) => setDialogState(
                                                () => selectedAccount =
                                                    val?.accountName),
                                            decoratorProps:
                                                const DropDownDecoratorProps(
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        8),
                                                        border:
                                                            InputBorder.none,
                                                        hintText: "Select")),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Payment Mode",
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200)),
                                          child: DropdownSearch<String>(
                                            compareFn: (i, s) => i == s,
                                            items: (f, p) => [
                                              "Cash",
                                              "Online",
                                              "Credit By Transfer"
                                            ],
                                            onChanged: (val) => setDialogState(
                                                () => paymentMode = val),
                                            selectedItem: paymentMode,
                                            decoratorProps:
                                                const DropDownDecoratorProps(
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        8),
                                                        border:
                                                            InputBorder.none)),
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
                                      child: _buildInputLabelField(
                                        label: "TR Reference No",
                                        child: TextField(
                                            controller: trRefNoController,
                                            decoration:
                                                _inputDecoration("TR #")),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  trRefDate ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100));
                                          if (picked != null)
                                            setDialogState(
                                                () => trRefDate = picked);
                                        },
                                        child: _buildInputLabelField(
                                          label: "TR Ref Date",
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 16,
                                                    color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Text(
                                                    trRefDate != null
                                                        ? DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(trRefDate!)
                                                        : "Select Date",
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabelField(
                                  label: "Transaction Remark",
                                  child: TextField(
                                      controller: transRemarkController,
                                      decoration:
                                          _inputDecoration("Enter remark...")),
                                ),
                              ],
                              const Divider(height: 40),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                            context: context,
                                            initialDate: deliveryDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100));
                                        if (picked != null)
                                          setDialogState(
                                              () => deliveryDate = picked);
                                      },
                                      child: _buildInputLabelField(
                                        label: "Delivery Date",
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color:
                                                      Colors.grey.shade200)),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons
                                                      .local_shipping_outlined,
                                                  size: 16,
                                                  color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(
                                                  deliveryDate != null
                                                      ? DateFormat(
                                                              'dd-MM-yyyy')
                                                          .format(
                                                              deliveryDate!)
                                                      : "Select Date",
                                                  style: const TextStyle(
                                                      fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInputLabelField(
                                      label: "Upload Order Copy",
                                      child: InkWell(
                                        onTap: () async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles();
                                          if (result != null) {
                                            setDialogState(() =>
                                                orderCopyFile =
                                                    result.files.first);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color:
                                                      Colors.grey.shade200)),
                                          child: Row(
                                            children: [
                                              Icon(Icons.upload_file,
                                                  size: 16,
                                                  color: orderCopyFile != null
                                                      ? Colors.blue
                                                      : Colors.grey),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                    orderCopyFile != null
                                                        ? orderCopyFile!.name
                                                        : "Choose File",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: orderCopyFile !=
                                                                null
                                                            ? Colors.black
                                                            : Colors.grey,
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInputLabelField(
                                label: "Remarks/Notes",
                                child: TextField(
                                  controller: remarksController,
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                      "Add any additional notes..."),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5))
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedSupplier == null) {
                                Common.toastMessaage("Please select a supplier", Colors.red);
                                return;
                              }
                              if (addressController.text.trim().isEmpty) {
                                Common.toastMessaage("Please enter billing address", Colors.red);
                                return;
                              }
                              if (cartItems.isEmpty) {
                                Common.toastMessaage("Please add at least one item to cart", Colors.red);
                                return;
                              }
                              showDialog(
                                context: dialogContext,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              
                              try {
                                Map<String, dynamic> postData = {};
                                postData['order_date'] = DateFormat('yyyy-MM-dd').format(orderDate);
                                postData['supplier_id'] = selectedSupplier!.supplierId;
                                postData['ref_no'] = refNoController.text.trim();
                                postData['address'] = addressController.text.trim();
                                List<Map<String, dynamic>> itemsList = [];
                                for (var item in cartItems) {
                                  itemsList.add({
                                    'material_id': item.material.materialId,
                                    'quantity': item.quantity.toString(),
                                    'unit_price': item.unitPrice.toString(),
                                    'total_price': item.total.toString(),
                                  });
                                }
                                postData['items'] = itemsList;
                                double advancePaid = double.tryParse(advancePaidController.text.trim()) ?? 0;
                                postData['advance_paid'] = advancePaid.toString();
                                postData['paid_date'] = paidDate != null ? DateFormat('yyyy-MM-dd').format(paidDate!) : '';
                                postData['paid_from_account'] = selectedAccount ?? '';
                                postData['payment_mode'] = paymentMode ?? '';
                                postData['tr_ref_no'] = trRefNoController.text.trim();
                                postData['tr_ref_date'] = trRefDate != null ? DateFormat('yyyy-MM-dd').format(trRefDate!) : '';
                                postData['transaction_remark'] = transRemarkController.text.trim();
                                postData['delivery_date'] = deliveryDate != null ? DateFormat('yyyy-MM-dd').format(deliveryDate!) : '';
                                postData['remarks'] = remarksController.text.trim();
                                
                                if (orderCopyFile != null && orderCopyFile!.path != null) {
                                  postData['order_copy'] = await dio.MultipartFile.fromFile(
                                    orderCopyFile!.path!,
                                    filename: orderCopyFile!.name,
                                  );
                                }

                                double totalAmount = cartItems.fold(0, (sum, item) => sum + item.total);
                                postData['total_estimated_amt'] = totalAmount.toString();
                                postData['user_id'] = widget.userId;
                                postData['created_by'] = widget.name;

                                dynamic response;
                                if (editData != null) {
                                  postData['purchase_order_id'] =
                                      editData.orderDetails!.purchaseOrderId;
                                  response = await HttpService.updatePurchaseOrder(
                                      postData);
                                } else {
                                  response =
                                      await HttpService.postPurchaseOrder(postData);
                                }

                                Navigator.pop(dialogContext);
                                if (response != null && response['status'] == true) {
                                  Common.toastMessaage(
                                    response['message'] ??
                                        (editData == null
                                            ? "Purchase Order Submitted Successfully"
                                            : "Purchase Order Updated Successfully"),
                                    Colors.green,
                                  );
                                  Navigator.pop(dialogContext);
                                  _fetchOrders();
                                } else {
                                  Common.toastMessaage(
                                    response?['message'] ??
                                        "Failed to process purchase order",
                                    Colors.red,
                                  );
                                }
                              } catch (e) {
                                Navigator.pop(dialogContext);
                                Common.toastMessaage("Error: ${e.toString()}", Colors.red);
                                print("Error posting purchase order: $e");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 12),
                                Text(
                                    editData == null
                                        ? "SUBMIT ORDER"
                                        : "UPDATE ORDER",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1.2)),
                              ],
                            ),
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

  // void _showOrderDialog({details.PurchaseOrderData? editData}) {
  //   List<CartItem> cartItems = [];
  //   DateTime orderDate = DateTime.now();
  //   DateTime? paidDate = DateTime.now();
  //   DateTime? deliveryDate;
  //   DateTime? trRefDate = DateTime.now();

  //   MaterialData? selectedMaterial;
  //   Supplier? selectedSupplier;
  //   String? selectedAccount;
  //   String? paymentMode = "Cash";
  //   PlatformFile? orderCopyFile;

  //   final TextEditingController refNoController = TextEditingController();
  //   final TextEditingController addressController = TextEditingController();
  //   final TextEditingController advancePaidController = TextEditingController();
  //   final TextEditingController trRefNoController = TextEditingController();
  //   final TextEditingController transRemarkController = TextEditingController();
  //   final TextEditingController remarksController = TextEditingController();

  //   if (editData != null && editData.orderDetails != null) {
  //     var d = editData.orderDetails!;
  //     try {
  //       orderDate = DateFormat('yyyy-MM-dd').parse(d.orderDate!);
  //     } catch (e) {}
  //     selectedSupplier = suppliers.any((s) => s.supplierId == d.supplierId)
  //         ? suppliers.firstWhere((s) => s.supplierId == d.supplierId)
  //         : null;
  //     paymentMode = d.paymentMethod ?? "Cash";
  //     advancePaidController.text = d.advanceAmount ?? "";
  //     refNoController.text = d.referenceNo ?? d.refNo ?? "";
  //     addressController.text = d.billingAddress ?? d.address ?? "";
  //     remarksController.text = d.remarks ?? "";
  //     if (d.deliveryDate != null && d.deliveryDate!.isNotEmpty) {
  //       try {
  //         deliveryDate = DateFormat('yyyy-MM-dd').parse(d.deliveryDate!);
  //       } catch (e) {}
  //     }
  //   }

  //   if (editData != null && editData.items != null) {
  //     cartItems = editData.items!.map((item) {
  //       return CartItem(
  //         material: MaterialData(
  //           materialId: item.materialId,
  //           materialName: item.materialName,
  //           unitPrice: item.unitPrice,
  //         ),
  //         quantity: double.tryParse(item.quantity ?? "1") ?? 1.0,
  //         unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,
  //       );
  //     }).toList();
  //   }

  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierLabel: "AddPurchaseOrder",
  //     barrierColor: Colors.black.withOpacity(0.6),
  //     transitionDuration: const Duration(milliseconds: 400),
  //     transitionBuilder: (context, anim1, anim2, child) {
  //       return FadeTransition(
  //         opacity: anim1,
  //         child: ScaleTransition(
  //           scale: Tween<double>(begin: 0.95, end: 1.0).animate(
  //             CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
  //           ),
  //           child: child,
  //         ),
  //       );
  //     },
  //     pageBuilder: (context, anim1, anim2) {
  //       List<MaterialData> dialogMaterials = [];
  //       List<ListElement> accountHeads = [];
  //       bool isFetching = false;
  //       bool isFetchingAccounts = false;

  //       return StatefulBuilder(
  //         builder: (dialogContext, setDialogState) {
  //           if (dialogMaterials.isEmpty && !isFetching) {
  //             isFetching = true;
  //             HttpService.getMaterials().then((val) {
  //               if (val != null && val.data != null && dialogContext.mounted) {
  //                 setDialogState(() {
  //                   dialogMaterials = val.data!;
  //                   isFetching = false;
  //                 });
  //               }
  //             });
  //           }

  //           if (accountHeads.isEmpty && !isFetchingAccounts) {
  //             isFetchingAccounts = true;
  //             HttpService.getAccountHead().then((val) {
  //               if (val != null && val.data != null && dialogContext.mounted) {
  //                 setDialogState(() {
  //                   accountHeads = val.data!.lists;
  //                   isFetchingAccounts = false;
  //                 });
  //               }
  //             });
  //           }

  //           double totalAmount =
  //               cartItems.fold(0, (sum, item) => sum + item.total);

  //           return Scaffold(
  //             backgroundColor: Colors.transparent,
  //             body: Center(
  //               child: Container(
  //                 width: MediaQuery.of(context).size.width * 0.95,
  //                 height: MediaQuery.of(context).size.height * 0.9,
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFF8FAFC),
  //                   borderRadius: BorderRadius.circular(30),
  //                   boxShadow: [
  //                     BoxShadow(
  //                         color: Colors.black.withOpacity(0.2),
  //                         blurRadius: 20,
  //                         offset: const Offset(0, 10))
  //                   ],
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(30),
  //                   child: Column(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 24, vertical: 20),
  //                         decoration: const BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [Color(0xFF2a86c9), Color(0xFF1e6399)],
  //                             begin: Alignment.topLeft,
  //                             end: Alignment.bottomRight,
  //                           ),
  //                         ),
  //                         child: Row(
  //                           children: [
  //                             Container(
  //                               padding: const EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                   color: Colors.white.withOpacity(0.2),
  //                                   borderRadius: BorderRadius.circular(12)),
  //                               child: const Icon(Icons.shopping_cart_checkout,
  //                                   color: Colors.white, size: 24),
  //                             ),
  //                             const SizedBox(width: 16),
  //                             Expanded(
  //                               child: Text(
  //                                 editData == null
  //                                     ? "Purchase Order"
  //                                     : "Edit Purchase Order",
  //                                 style: const TextStyle(
  //                                     color: Colors.white,
  //                                     fontSize: 20,
  //                                     fontWeight: FontWeight.bold,
  //                                     letterSpacing: 0.5),
  //                               ),
  //                             ),
  //                             IconButton(
  //                               icon: const Icon(Icons.close,
  //                                   color: Colors.white, size: 26),
  //                               onPressed: () => Navigator.pop(context),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SingleChildScrollView(
  //                           padding: const EdgeInsets.all(24),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               _buildSectionHeader(
  //                                   "Order Details", Icons.assignment_outlined),
  //                               const SizedBox(height: 16),
  //                               Row(
  //                                 children: [
  //                                   Expanded(
  //                                     child: _buildGlassCard(
  //                                       title: "Order No",
  //                                       value:
  //                                           "#${DateFormat('HHmmss').format(DateTime.now())}",
  //                                       icon: Icons.tag,
  //                                       color: const Color(0xFF2a86c9),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 12),
  //                                   Expanded(
  //                                     child: InkWell(
  //                                       onTap: () async {
  //                                         final picked = await showDatePicker(
  //                                           context: context,
  //                                           initialDate: orderDate,
  //                                           firstDate: DateTime(2000),
  //                                           lastDate: DateTime(2100),
  //                                         );
  //                                         if (picked != null)
  //                                           setDialogState(
  //                                               () => orderDate = picked);
  //                                       },
  //                                       child: _buildGlassCard(
  //                                         title: "Order Date",
  //                                         value: DateFormat('dd-MM-yyyy')
  //                                             .format(orderDate),
  //                                         icon: Icons.calendar_today,
  //                                         color: Colors.orange,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(height: 20),
  //                               Row(
  //                                 children: [
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: _buildInputLabelField(
  //                                       label: "Supplier Name*",
  //                                       child: Container(
  //                                         decoration: BoxDecoration(
  //                                           color: Colors.white,
  //                                           borderRadius:
  //                                               BorderRadius.circular(15),
  //                                           border: Border.all(
  //                                               color: Colors.grey.shade200),
  //                                         ),
  //                                           child: DropdownSearch<Supplier>(
  //                                           compareFn: (item, selectedItem) =>
  //                                               item.supplierId ==
  //                                               selectedItem?.supplierId,
  //                                           selectedItem: selectedSupplier,
  //                                           items: (f, p) => suppliers,
  //                                           itemAsString: (s) => s.supplierName,
  //                                           decoratorProps:
  //                                               const DropDownDecoratorProps(
  //                                             decoration: InputDecoration(
  //                                               contentPadding:
  //                                                   EdgeInsets.symmetric(
  //                                                       horizontal: 16,
  //                                                       vertical: 8),
  //                                               border: InputBorder.none,
  //                                               hintText: "Select Supplier",
  //                                             ),
  //                                           ),
  //                                           onChanged: (val) => setDialogState(
  //                                               () => selectedSupplier = val),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 12),
  //                                   Expanded(
  //                                     child: _buildInputLabelField(
  //                                       label: "Reference No",
  //                                       child: TextField(
  //                                         controller: refNoController,
  //                                         decoration: _inputDecoration("Ref #"),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(height: 16),
  //                               _buildInputLabelField(
  //                                 label: "Billing Address*",
  //                                 child: TextField(
  //                                   controller: addressController,
  //                                   maxLines: 2,
  //                                   decoration: _inputDecoration(
  //                                       "Enter full billing address..."),
  //                                 ),
  //                               ),
  //                               const Divider(height: 40),
  //                               _buildSectionHeader("Add Items to Cart",
  //                                   Icons.add_shopping_cart_rounded),
  //                               const SizedBox(height: 16),
  //                               Container(
  //                                 padding: const EdgeInsets.all(20),
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.white,
  //                                   borderRadius: BorderRadius.circular(25),
  //                                   border:
  //                                       Border.all(color: Colors.grey.shade100),
  //                                   boxShadow: [
  //                                     BoxShadow(
  //                                         color: Colors.black.withOpacity(0.03),
  //                                         blurRadius: 15,
  //                                         offset: const Offset(0, 5))
  //                                   ],
  //                                 ),
  //                                 child: Column(
  //                                   children: [
  //                                     DropdownSearch<MaterialData>(
  //                                       compareFn: (i, s) =>
  //                                           i?.materialId == s?.materialId,
  //                                       items: (f, p) => dialogMaterials
  //                                           .where((m) =>
  //                                               m.materialName
  //                                                   ?.toLowerCase()
  //                                                   .contains(
  //                                                       f.toLowerCase()) ??
  //                                               true)
  //                                           .toList(),
  //                                       itemAsString: (m) =>
  //                                           m.materialName ?? "",
  //                                       decoratorProps:
  //                                           const DropDownDecoratorProps(
  //                                         decoration: InputDecoration(
  //                                           hintText: "Search material",
  //                                           border: OutlineInputBorder(
  //                                               borderRadius: BorderRadius.all(
  //                                                   Radius.circular(15))),
  //                                           prefixIcon: Icon(
  //                                               Icons.inventory_2_outlined),
  //                                         ),
  //                                       ),
  //                                       popupProps: const PopupProps.menu(
  //                                           showSearchBox: true),
  //                                       onChanged: (val) => setDialogState(
  //                                           () => selectedMaterial = val),
  //                                     ),
  //                                     const SizedBox(height: 16),
  //                                     SizedBox(
  //                                       width: double.infinity,
  //                                       child: ElevatedButton.icon(
  //                                         onPressed: () {
  //                                           if (selectedMaterial != null) {
  //                                             setDialogState(() {
  //                                               cartItems.add(CartItem(
  //                                                 material: selectedMaterial!,
  //                                                 unitPrice: double.tryParse(
  //                                                         selectedMaterial!
  //                                                                 .unitPrice ??
  //                                                             "0") ??
  //                                                     0.0,
  //                                               ));
  //                                               selectedMaterial = null;
  //                                             });
  //                                           }
  //                                         },
  //                                         icon: const Icon(Icons.add,
  //                                             color: Colors.white),
  //                                         label: const Text("ADD TO CART",
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontWeight: FontWeight.bold)),
  //                                         style: ElevatedButton.styleFrom(
  //                                           backgroundColor:
  //                                               const Color(0xFF2a86c9),
  //                                           padding: const EdgeInsets.symmetric(
  //                                               vertical: 15),
  //                                           shape: RoundedRectangleBorder(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(15)),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 24),
  //                               Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   const Text("Cart Items",
  //                                       style: TextStyle(
  //                                           fontSize: 16,
  //                                           fontWeight: FontWeight.bold)),
  //                                   Container(
  //                                     padding: const EdgeInsets.symmetric(
  //                                         horizontal: 12, vertical: 4),
  //                                     decoration: BoxDecoration(
  //                                         color: const Color(0xFF2a86c9)
  //                                             .withOpacity(0.1),
  //                                         borderRadius:
  //                                             BorderRadius.circular(20)),
  //                                     child: Text("${cartItems.length} Items",
  //                                         style: const TextStyle(
  //                                             color: Color(0xFF2a86c9),
  //                                             fontWeight: FontWeight.bold,
  //                                             fontSize: 12)),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(height: 12),
  //                               cartItems.isEmpty
  //                                   ? _buildEmptyCart()
  //                                   : Column(
  //                                       children: List.generate(
  //                                           cartItems.length, (index) {
  //                                         return _buildCartItemCard(
  //                                             cartItems[index],
  //                                             index,
  //                                             setDialogState, () {
  //                                           setDialogState(() {
  //                                             cartItems[index].dispose();
  //                                             cartItems.removeAt(index);
  //                                           });
  //                                         });
  //                                       }),
  //                                     ),
  //                               const SizedBox(height: 20),
  //                               Container(
  //                                 padding: const EdgeInsets.all(16),
  //                                 decoration: BoxDecoration(
  //                                     color: const Color(0xFF2a86c9)
  //                                         .withOpacity(0.05),
  //                                     borderRadius: BorderRadius.circular(15)),
  //                                 child: Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     const Text("Total Estimated Amount",
  //                                         style: TextStyle(
  //                                             fontWeight: FontWeight.bold)),
  //                                     Text("₹${totalAmount.toStringAsFixed(2)}",
  //                                         style: const TextStyle(
  //                                             color: Color(0xFF2a86c9),
  //                                             fontWeight: FontWeight.bold,
  //                                             fontSize: 18)),
  //                                   ],
  //                                 ),
  //                               ),
  //                               const Divider(height: 40),
  //                               _buildSectionHeader(
  //                                   "Payment Details", Icons.payments_outlined),
  //                               const SizedBox(height: 16),
  //                               Row(
  //                                 children: [
  //                                   Expanded(
  //                                     child: _buildInputLabelField(
  //                                       label: "Advance Paid",
  //                                       child: TextField(
  //                                         controller: advancePaidController,
  //                                         keyboardType: TextInputType.number,
  //                                         decoration:
  //                                             _inputDecoration("₹ 0.00"),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   if (editData == null) ...[
  //                                     const SizedBox(width: 12),
  //                                     Expanded(
  //                                       child: InkWell(
  //                                         onTap: () async {
  //                                           final picked = await showDatePicker(
  //                                               context: context,
  //                                               initialDate:
  //                                                   paidDate ?? DateTime.now(),
  //                                               firstDate: DateTime(2000),
  //                                               lastDate: DateTime(2100));
  //                                           if (picked != null)
  //                                             setDialogState(
  //                                                 () => paidDate = picked);
  //                                         },
  //                                         child: _buildInputLabelField(
  //                                           label: "Paid Date",
  //                                           child: Container(
  //                                             padding: const EdgeInsets.symmetric(
  //                                                 horizontal: 16, vertical: 12),
  //                                             decoration: BoxDecoration(
  //                                                 color: Colors.white,
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(15),
  //                                                 border: Border.all(
  //                                                     color:
  //                                                         Colors.grey.shade200)),
  //                                             child: Row(
  //                                               children: [
  //                                                 const Icon(Icons.calendar_today,
  //                                                     size: 16,
  //                                                     color: Colors.grey),
  //                                                 const SizedBox(width: 8),
  //                                                 Text(
  //                                                     paidDate != null
  //                                                         ? DateFormat(
  //                                                                 'dd-MM-yyyy')
  //                                                             .format(paidDate!)
  //                                                         : "Select Date",
  //                                                     style: const TextStyle(
  //                                                         fontSize: 13)),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ],
  //                               ),
  //                               if (editData == null) ...[
  //                                 const SizedBox(height: 16),
  //                                 Row(
  //                                   children: [
  //                                     Expanded(
  //                                       child: _buildInputLabelField(
  //                                         label: "Paid From Account",
  //                                         child: Container(
  //                                           decoration: BoxDecoration(
  //                                               color: Colors.white,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(15),
  //                                               border: Border.all(
  //                                                   color: Colors.grey.shade200)),
  //                                           child: DropdownSearch<ListElement>(
  //                                             compareFn: (i, s) =>
  //                                                 i.accountId == s?.accountId,
  //                                             selectedItem: accountHeads.any((a) =>
  //                                                     a.accountName ==
  //                                                     selectedAccount)
  //                                                 ? accountHeads.firstWhere((a) =>
  //                                                     a.accountName ==
  //                                                     selectedAccount)
  //                                                 : null,
  //                                             items: (f, p) => accountHeads
  //                                                 .where((a) => a.accountName
  //                                                     .toLowerCase()
  //                                                     .contains(f.toLowerCase()))
  //                                                 .toList(),
  //                                             itemAsString: (a) => a.accountName,
  //                                             onChanged: (val) => setDialogState(
  //                                                 () => selectedAccount =
  //                                                     val?.accountName),
  //                                             decoratorProps:
  //                                                 const DropDownDecoratorProps(
  //                                                     decoration: InputDecoration(
  //                                                         contentPadding:
  //                                                             EdgeInsets
  //                                                                 .symmetric(
  //                                                                     horizontal:
  //                                                                         16,
  //                                                                     vertical:
  //                                                                         8),
  //                                                         border:
  //                                                             InputBorder.none,
  //                                                         hintText: "Select")),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 12),
  //                                     Expanded(
  //                                       child: _buildInputLabelField(
  //                                         label: "Payment Mode",
  //                                         child: Container(
  //                                           decoration: BoxDecoration(
  //                                               color: Colors.white,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(15),
  //                                               border: Border.all(
  //                                                   color: Colors.grey.shade200)),
  //                                           child: DropdownSearch<String>(
  //                                             compareFn: (i, s) => i == s,
  //                                             items: (f, p) => [
  //                                               "Cash",
  //                                               "Online",
  //                                               "Credit By Transfer"
  //                                             ],
  //                                             onChanged: (val) => setDialogState(
  //                                                 () => paymentMode = val),
  //                                             selectedItem: paymentMode,
  //                                             decoratorProps:
  //                                                 const DropDownDecoratorProps(
  //                                                     decoration: InputDecoration(
  //                                                         contentPadding:
  //                                                             EdgeInsets
  //                                                                 .symmetric(
  //                                                                     horizontal:
  //                                                                         16,
  //                                                                     vertical:
  //                                                                         8),
  //                                                         border:
  //                                                             InputBorder.none)),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 const SizedBox(height: 16),
  //                                 Row(
  //                                   children: [
  //                                     Expanded(
  //                                       child: _buildInputLabelField(
  //                                         label: "TR Reference No",
  //                                         child: TextField(
  //                                             controller: trRefNoController,
  //                                             decoration:
  //                                                 _inputDecoration("TR #")),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 12),
  //                                     Expanded(
  //                                       child: InkWell(
  //                                         onTap: () async {
  //                                           final picked = await showDatePicker(
  //                                               context: context,
  //                                               initialDate:
  //                                                   trRefDate ?? DateTime.now(),
  //                                               firstDate: DateTime(2000),
  //                                               lastDate: DateTime(2100));
  //                                           if (picked != null)
  //                                             setDialogState(
  //                                                 () => trRefDate = picked);
  //                                         },
  //                                         child: _buildInputLabelField(
  //                                           label: "TR Ref Date",
  //                                           child: Container(
  //                                             padding: const EdgeInsets.symmetric(
  //                                                 horizontal: 16, vertical: 12),
  //                                             decoration: BoxDecoration(
  //                                                 color: Colors.white,
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(15),
  //                                                 border: Border.all(
  //                                                     color:
  //                                                         Colors.grey.shade200)),
  //                                             child: Row(
  //                                               children: [
  //                                                 const Icon(Icons.calendar_today,
  //                                                     size: 16,
  //                                                     color: Colors.grey),
  //                                                 const SizedBox(width: 8),
  //                                                 Text(
  //                                                     trRefDate != null
  //                                                         ? DateFormat(
  //                                                                 'dd-MM-yyyy')
  //                                                             .format(trRefDate!)
  //                                                         : "Select Date",
  //                                                     style: const TextStyle(
  //                                                         fontSize: 13)),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 const SizedBox(height: 16),
  //                                 _buildInputLabelField(
  //                                   label: "Transaction Remark",
  //                                   child: TextField(
  //                                       controller: transRemarkController,
  //                                       decoration:
  //                                           _inputDecoration("Enter remark...")),
  //                                 ),
  //                               ],
  //                               const Divider(height: 40),
  //                               Row(
  //                                 children: [
  //                                   Expanded(
  //                                     child: InkWell(
  //                                       onTap: () async {
  //                                         final picked = await showDatePicker(
  //                                             context: context,
  //                                             initialDate: deliveryDate ??
  //                                                 DateTime.now(),
  //                                             firstDate: DateTime(2000),
  //                                             lastDate: DateTime(2100));
  //                                         if (picked != null)
  //                                           setDialogState(
  //                                               () => deliveryDate = picked);
  //                                       },
  //                                       child: _buildInputLabelField(
  //                                         label: "Delivery Date",
  //                                         child: Container(
  //                                           padding: const EdgeInsets.symmetric(
  //                                               horizontal: 16, vertical: 12),
  //                                           decoration: BoxDecoration(
  //                                               color: Colors.white,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(15),
  //                                               border: Border.all(
  //                                                   color:
  //                                                       Colors.grey.shade200)),
  //                                           child: Row(
  //                                             children: [
  //                                               const Icon(
  //                                                   Icons
  //                                                       .local_shipping_outlined,
  //                                                   size: 16,
  //                                                   color: Colors.grey),
  //                                               const SizedBox(width: 8),
  //                                               Text(
  //                                                   deliveryDate != null
  //                                                       ? DateFormat(
  //                                                               'dd-MM-yyyy')
  //                                                           .format(
  //                                                               deliveryDate!)
  //                                                       : "Select Date",
  //                                                   style: const TextStyle(
  //                                                       fontSize: 13)),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 12),
  //                                   Expanded(
  //                                     child: _buildInputLabelField(
  //                                       label: "Upload Order Copy",
  //                                       child: InkWell(
  //                                         onTap: () async {
  //                                           FilePickerResult? result =
  //                                               await FilePicker.platform
  //                                                   .pickFiles();
  //                                           if (result != null) {
  //                                             setDialogState(() =>
  //                                                 orderCopyFile =
  //                                                     result.files.first);
  //                                           }
  //                                         },
  //                                         child: Container(
  //                                           padding: const EdgeInsets.symmetric(
  //                                               horizontal: 16, vertical: 12),
  //                                           decoration: BoxDecoration(
  //                                               color: Colors.white,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(15),
  //                                               border: Border.all(
  //                                                   color:
  //                                                       Colors.grey.shade200)),
  //                                           child: Row(
  //                                             children: [
  //                                               Icon(Icons.upload_file,
  //                                                   size: 16,
  //                                                   color: orderCopyFile != null
  //                                                       ? Colors.blue
  //                                                       : Colors.grey),
  //                                               const SizedBox(width: 8),
  //                                               Expanded(
  //                                                 child: Text(
  //                                                     orderCopyFile != null
  //                                                         ? orderCopyFile!.name
  //                                                         : "Choose File",
  //                                                     style: TextStyle(
  //                                                         fontSize: 13,
  //                                                         color: orderCopyFile !=
  //                                                                 null
  //                                                             ? Colors.black
  //                                                             : Colors.grey,
  //                                                         overflow: TextOverflow
  //                                                             .ellipsis)),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(height: 16),
  //                               _buildInputLabelField(
  //                                 label: "Remarks/Notes",
  //                                 child: TextField(
  //                                   controller: remarksController,
  //                                   maxLines: 3,
  //                                   decoration: _inputDecoration(
  //                                       "Add any additional notes..."),
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 40),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       Container(
  //                         padding: const EdgeInsets.all(24),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           boxShadow: [
  //                             BoxShadow(
  //                                 color: Colors.black.withOpacity(0.05),
  //                                 blurRadius: 10,
  //                                 offset: const Offset(0, -5))
  //                           ],
  //                         ),
  //                         child: SizedBox(
  //                           width: double.infinity,
  //                           child: ElevatedButton(
  //                         onPressed: () async {
  //                           if (selectedSupplier == null) {
  //                             Common.toastMessaage("Please select a supplier", Colors.red);
  //                             return;
  //                           }
  //                           if (addressController.text.trim().isEmpty) {
  //                             Common.toastMessaage("Please enter billing address", Colors.red);
  //                             return;
  //                           }
  //                           if (cartItems.isEmpty) {
  //                             Common.toastMessaage("Please add at least one item to cart", Colors.red);
  //                             return;
  //                           }
  //                           showDialog(
  //                             context: dialogContext,
  //                             barrierDismissible: false,
  //                             builder: (context) => const Center(
  //                               child: CircularProgressIndicator(),
  //                             ),
  //                           );
                            
  //                           try {
  //                             Map<String, dynamic> postData = {};
  //                             postData['order_date'] = DateFormat('yyyy-MM-dd').format(orderDate);
  //                             postData['supplier_id'] = selectedSupplier!.supplierId;
  //                             postData['ref_no'] = refNoController.text.trim();
  //                             postData['address'] = addressController.text.trim();
  //                             List<Map<String, dynamic>> itemsList = [];
  //                             for (var item in cartItems) {
  //                               itemsList.add({
  //                                 'material_id': item.material.materialId,
  //                                 'quantity': item.quantity.toString(),
  //                                 'unit_price': item.unitPrice.toString(),
  //                                 'total_price': item.total.toString(),
  //                               });
  //                             }
  //                             postData['items'] = itemsList;
  //                             double advancePaid = double.tryParse(advancePaidController.text.trim()) ?? 0;
  //                             postData['advance_paid'] = advancePaid.toString();
  //                             postData['paid_date'] = paidDate != null ? DateFormat('yyyy-MM-dd').format(paidDate!) : '';
  //                             postData['paid_from_account'] = selectedAccount ?? '';
  //                             postData['payment_mode'] = paymentMode ?? '';
  //                             postData['tr_ref_no'] = trRefNoController.text.trim();
  //                             postData['tr_ref_date'] = trRefDate != null ? DateFormat('yyyy-MM-dd').format(trRefDate!) : '';
  //                             postData['transaction_remark'] = transRemarkController.text.trim();
  //                             postData['delivery_date'] = deliveryDate != null ? DateFormat('yyyy-MM-dd').format(deliveryDate!) : '';
  //                             postData['remarks'] = remarksController.text.trim();
                              
  //                             if (orderCopyFile != null && orderCopyFile!.path != null) {
  //                               postData['order_copy'] = await dio.MultipartFile.fromFile(
  //                                 orderCopyFile!.path!,
  //                                 filename: orderCopyFile!.name,
  //                               );
  //                             }

  //                             double totalAmount = cartItems.fold(0, (sum, item) => sum + item.total);
  //                             postData['total_estimated_amt'] = totalAmount.toString();
  //                             postData['user_id'] = widget.userId;
  //                             postData['created_by'] = widget.name;

  //                             dynamic response;
  //                             if (editData != null) {
  //                               postData['purchase_order_id'] =
  //                                   editData.orderDetails!.purchaseOrderId;
  //                               response = await HttpService.updatePurchaseOrder(
  //                                   postData);
  //                             } else {
  //                               response =
  //                                   await HttpService.postPurchaseOrder(postData);
  //                             }

  //                             Navigator.pop(dialogContext);
  //                             if (response != null && response['status'] == true) {
  //                               Common.toastMessaage(
  //                                 response['message'] ??
  //                                     (editData == null
  //                                         ? "Purchase Order Submitted Successfully"
  //                                         : "Purchase Order Updated Successfully"),
  //                                 Colors.green,
  //                               );
  //                               Navigator.pop(dialogContext);
  //                               _fetchOrders();
  //                             } else {
  //                               Common.toastMessaage(
  //                                 response?['message'] ??
  //                                     "Failed to process purchase order",
  //                                 Colors.red,
  //                               );
  //                             }
  //                           } catch (e) {
  //                             Navigator.pop(dialogContext);
  //                             Common.toastMessaage("Error: ${e.toString()}", Colors.red);
  //                             print("Error posting purchase order: $e");
  //                           }
  //                         },
  //                             // onPressed: () {
  //                             //   Common.toastMessaage(
  //                             //       "Purchase Order Submitted", Colors.green);
  //                             //   Navigator.pop(context);
  //                             //   _fetchOrders();
  //                             // },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: const Color(0xFF2a86c9),
  //                               padding:
  //                                   const EdgeInsets.symmetric(vertical: 18),
  //                               shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(18)),
  //                               elevation: 0,
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(Icons.send_rounded,
  //                                     color: Colors.white, size: 20),
  //                                 SizedBox(width: 12),
  //                                 Text(
  //                                     editData == null
  //                                         ? "SUBMIT ORDER"
  //                                         : "UPDATE ORDER",
  //                                     style: const TextStyle(
  //                                         color: Colors.white,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 16,
  //                                         letterSpacing: 1.2)),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setFilterState) {
        return Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Orders',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
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
                      child: _buildDatePicker('From', fromDate,
                          (date) => setFilterState(() => fromDate = date))),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildDatePicker('To', toDate,
                          (date) => setFilterState(() => toDate = date))),
                ],
              ),
              const SizedBox(height: 25),
              const Text('Approval Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ["All", "Pending", "Approved", "Rejected", "Bill Created"]
                    .map((status) {
                  bool isSelected = selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) =>
                        setFilterState(() => selectedStatus = status),
                    selectedColor: const Color(0xFF2a86c9).withOpacity(0.1),
                    labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2a86c9)
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2a86c9)
                            : Colors.grey.shade300),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              const Text('Supplier',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownSearch<Supplier>(
                  items: (f, p) => suppliers,
                  itemAsString: (s) => s.supplierName,
                  compareFn: (item, selectedItem) =>
                      item.supplierId == selectedItem?.supplierId,
                  onChanged: (val) =>
                      setFilterState(() => selectedSupplierFilter = val),
                  selectedItem: selectedSupplierFilter,
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
                        setFilterState(() {
                          fromDate = null;
                          toDate = null;
                          selectedStatus = "All";
                          selectedSupplierFilter = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _fetchOrders();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text('Apply Filter',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void _showViewDrawer(PurchaseOrderData order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF2a86c9).withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag,
                        color: Color(0xFF2a86c9))),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order NO: #${order.orderId ?? 'N/A'}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Purchase Order Details',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
                _buildStatusBadge(order.billStatus ?? 'Pending'),
              ],
            ),
            const SizedBox(height: 30),
            _buildDetailRow(
                Icons.business, 'Supplier', order.supplierName ?? 'Unknown'),
            _buildDetailRow(Icons.calendar_today_outlined, 'Order Date',
                order.orderDate ?? 'N/A'),
            _buildDetailRow(Icons.currency_rupee, 'Estimated Amt',
                '₹${order.estimatedAmt ?? '0'}'),
            _buildDetailRow(
                Icons.payment, 'Advance Amt', '₹${order.advanceAmt ?? '0'}'),
            _buildDetailRow(Icons.account_balance_wallet_outlined,
                'Balance Amt', '₹${order.balanceAmt ?? '0'}'),
            const Divider(height: 40),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Address',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Text(order.address ?? 'No address provided',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text('Close',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Orders Found',
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

  Widget _buildGlassCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
          border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(title.toUpperCase(),
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5))
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 20, color: const Color(0xFF2a86c9)),
      const SizedBox(width: 12),
      Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.2))
    ]);
  }

  Widget _buildInputLabelField({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87)),
      const SizedBox(height: 8),
      child
    ]);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF2a86c9), width: 1.5)),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.grey.shade200, style: BorderStyle.solid)),
      child: Column(children: [
        Icon(Icons.shopping_cart_outlined,
            size: 40, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text("Your cart is empty",
            style: TextStyle(
                color: Colors.grey.shade400, fontWeight: FontWeight.w500))
      ]),
    );
  }

Widget _buildCartItemCard(
  CartItem item,
  int index,
  StateSetter setDialogState,
  VoidCallback onDelete,
  details.PurchaseOrderData? editData,
  BuildContext dialogContext,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100)),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Text(item.material.materialName ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            // Delete button with confirmation for edit mode
            if (editData != null && item.material.materialId != null)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () async {
                  // Show confirmation dialog
                  bool? confirm = await showDialog(
                    context: dialogContext,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Product'),
                      content: Text('Delete "${item.material.materialName}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    // Show loading
                    showDialog(
                      context: dialogContext,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    // Call API
                    final response = await HttpService.deletePurchaseOrderRealProduct(
                      productId: item.material.materialId!,
                    );
                    
                    Navigator.pop(dialogContext); // Close loading
                    
                    if (response?.status == true) {
                      Common.toastMessaage('Product deleted', Colors.green);
                      onDelete(); // Remove from cart
                    } else {
                      Common.toastMessaage(response?.message ?? 'Delete failed', Colors.red);
                    }
                  }
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Price",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  TextField(
                    controller: item.unitPriceController,
                    onChanged: (v) => setDialogState(
                        () => item.unitPrice = double.tryParse(v) ?? 0),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: "0.00",
                        isDense: true,
                        border: InputBorder.none),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Quantity",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 18),
                          onPressed: () => setDialogState(() =>
                              item.quantity > 1 ? item.quantity-- : null)),
                      Text(item.quantity.toInt().toString(),
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          icon:
                              const Icon(Icons.add_circle_outline, size: 18),
                          onPressed: () =>
                              setDialogState(() => item.quantity++)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("₹${item.total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2a86c9))),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  // Widget _buildCartItemCard(CartItem item, int index,
  //     StateSetter setDialogState, VoidCallback onDelete) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all(color: Colors.grey.shade100)),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //                 child: Text(item.material.materialName ?? "Unknown",
  //                     style: const TextStyle(fontWeight: FontWeight.bold))),
  //             IconButton(
  //                 icon: const Icon(Icons.delete_outline,
  //                     color: Colors.red, size: 20),
  //                 onPressed: onDelete),
  //           ],
  //         ),
  //         const Divider(),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text("Price",
  //                       style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                   TextField(
  //                     controller: item.unitPriceController,
  //                     onChanged: (v) => setDialogState(
  //                         () => item.unitPrice = double.tryParse(v) ?? 0),
  //                     keyboardType: TextInputType.number,
  //                     decoration: const InputDecoration(
  //                         hintText: "0.00",
  //                         isDense: true,
  //                         border: InputBorder.none),
  //                     style: const TextStyle(
  //                         fontWeight: FontWeight.bold, fontSize: 13),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: Column(
  //                 children: [
  //                   const Text("Quantity",
  //                       style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       IconButton(
  //                           icon: const Icon(Icons.remove_circle_outline,
  //                               size: 18),
  //                           onPressed: () => setDialogState(() =>
  //                               item.quantity > 1 ? item.quantity-- : null)),
  //                       Text(item.quantity.toInt().toString(),
  //                           style:
  //                               const TextStyle(fontWeight: FontWeight.bold)),
  //                       IconButton(
  //                           icon:
  //                               const Icon(Icons.add_circle_outline, size: 18),
  //                           onPressed: () =>
  //                               setDialogState(() => item.quantity++)),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 children: [
  //                   const Text("Amount",
  //                       style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                   Text("₹${item.total.toStringAsFixed(2)}",
  //                       style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Color(0xFF2a86c9))),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDatePicker(
      String label, DateTime? value, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)));
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(value != null ? DateFormat('dd/MM/yy').format(value) : label,
              style: TextStyle(
                  color: value != null ? Colors.black87 : Colors.grey.shade600,
                  fontSize: 12))
        ]),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 15),
          Text('$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.end))
        ]));
  }
}

class CartItem {
  final MaterialData material;
  double quantity;
  double unitPrice;
  String? description;
  late TextEditingController unitPriceController;

  CartItem({
    required this.material,
    this.quantity = 1.0,
    this.unitPrice = 0.0,
    this.description,
  }) {
    unitPriceController =
        TextEditingController(text: unitPrice > 0 ? unitPrice.toString() : "");
  }

  void dispose() {
    unitPriceController.dispose();
  }

  double get total => quantity * unitPrice;
}
