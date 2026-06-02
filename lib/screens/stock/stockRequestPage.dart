import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getStockRequestModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/stockRequestEditDetails.dart'
    as edit;
import 'package:login2/models/rental/rentalLocationModel.dart' as loc;
import 'package:login2/service/service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class StockRequestPage extends StatefulWidget {
  const StockRequestPage({super.key});

  @override
  State<StockRequestPage> createState() => _StockRequestPageState();
}

class _StockRequestPageState extends State<StockRequestPage> {
  bool _isLoading = true;
  List<StockRequestData> _requests = [];
  List<StockRequestData> _filteredRequests = [];
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String? _selectedProductId;
  String? _selectedLocationId;
  String? _selectedLocationName;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<loc.RetailLocation> _locations = [];
  List<MaterialData> _products = [];
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _loadInitialData();
    _searchController.addListener(_filterRequests);
  }

  Future<void> _loadInitialData() async {
    final locResponse = await HttpService.getRentalLocation();
    final prodResponse = await HttpService.getMaterials();
    final userName = await Common.getSharedPref("name");
    if (mounted) {
      setState(() {
        if (locResponse != null) _locations = locResponse.data;
        if (prodResponse != null) _products = prodResponse.data ?? [];
        _currentUserName = userName;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await HttpService.getRequestStockList(
        productId: _selectedProductId,
        locationId: _selectedLocationId,
        fromDate: _fromDate != null
            ? DateFormat('yyyy-MM-dd').format(_fromDate!)
            : null,
        toDate:
            _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null,
      );
      setState(() {
        if (response != null && response.status == true) {
          _requests = response.data ?? [];
          _filteredRequests = List.from(_requests);
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching stock requests: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterRequests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRequests = _requests.where((req) {
        return (req.productName?.toLowerCase().contains(query) ?? false) ||
            (req.requestedBy?.toLowerCase().contains(query) ?? false) ||
            (req.requestId?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Stock Requests',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRequests,
                    child: _filteredRequests.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredRequests.length,
                            itemBuilder: (context, index) =>
                                _buildRequestCard(_filteredRequests[index]),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NEW REQUEST",
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
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search requests...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryMiniCard("TOTAL", _requests.length.toString(),
                  Icons.analytics_outlined),
              const SizedBox(width: 12),
              _buildSummaryMiniCard(
                  "TODAY",
                  _requests
                      .where((r) =>
                          r.requiredDate ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now()))
                      .length
                      .toString(),
                  Icons.today_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMiniCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(StockRequestData item) {
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
                          Expanded(
                            child: Text(
                              item.productName ?? "Unknown Product",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                color: Colors.grey[400], size: 20),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddEditDialog(item: item);
                              } else if (value == 'delete') {
                                _deleteStockRequest(item.id ?? "");
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit,
                                        size: 18, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text("Edit"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text("Delete"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a86c9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "#${item.requestId ?? item.id}",
                              style: const TextStyle(
                                  color: Color(0xFF2a86c9),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      item.requestedBy != ""
                          ? const SizedBox(height: 12)
                          : SizedBox(),
                      item.requestedBy != ""
                          ? _buildInfoRow(Icons.person_outline, "Requested By",
                              item.requestedBy ?? "Unknown")
                          : SizedBox(),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.calendar_today_outlined,
                          "Required Date", item.requiredDate ?? "-"),
                      const Divider(height: 24),
                      Row(
                        children: [
                          _buildMiniStat("Quantity", item.quantity ?? "0"),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_forward_ios,
                                size: 10, color: Colors.grey[400]),
                          ),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text("$label: ",
            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF2a86c9))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No stock requests found",
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        products: _products,
        onApply: (from, to, productId, productName) {
          setState(() {
            _fromDate = from;
            _toDate = to;
            _selectedProductId = productId;
          });
          _fetchRequests();
        },
        onReset: () {
          setState(() {
            _fromDate = null;
            _toDate = null;
            _selectedProductId = null;
          });
          _fetchRequests();
        },
        initialFrom: _fromDate,
        initialTo: _toDate,
        initialProductId: _selectedProductId,
        initialProductName: _products
            .firstWhere(
              (p) => p.materialId == _selectedProductId,
              orElse: () => MaterialData(),
            )
            .materialName,
      ),
    );
  }

  Future<void> _deleteStockRequest(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content:
            const Text("Are you sure you want to delete this stock request?"),
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
      final response = await HttpService.deleteStockRequest(id);
      Navigator.pop(context); // Close dialog

      if (response != null && response.status == true) {
        Common.toastMessaage("Deleted successfully", Colors.green);
        _fetchRequests();
      } else {
        Common.toastMessaage(response?.message ?? "Delete failed", Colors.red);
      }
    }
  }

  Future<void> _showAddEditDialog({StockRequestData? item}) async {
    edit.StockRequestData? editData;
    if (item != null) {
      Common.showProgressDialog(context, "Fetching details...");
      final response =
          await HttpService.getStockRequestEditDetails(item.id ?? "");
      Navigator.pop(context); // Close progress dialog
      if (response != null && response.status == true) {
        editData = response.data;
      } else {
        Common.toastMessaage("Failed to fetch details", Colors.red);
        return;
      }
    }

    // Form State
    String? requestId = editData?.requestId ?? "AUTOGEN";

    DateTime? requiredDate;
    if (editData != null) {
      try {
        requiredDate = DateFormat('dd-MM-yyyy').parse(editData.requiredDate);
      } catch (e) {
        requiredDate = DateTime.tryParse(editData.requiredDate);
      }
    } else {
      requiredDate = DateTime.now().add(const Duration(days: 1));
    }

    String? productId = editData?.productId;
    String? productName = editData?.productName;
    String? locationId = editData?.locationId;
    String? locationName = editData?.locationName;
    String priority = editData?.priority ?? "Normal";
    String status = editData?.status ?? "Pending";
    final TextEditingController qtyController =
        TextEditingController(text: editData?.quantity ?? "");
    final TextEditingController remarkController =
        TextEditingController(text: editData?.remarks ?? "");
    final TextEditingController requestedByController = TextEditingController(
        text: editData?.requestedBy ?? _currentUserName ?? "");

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "StockRequestDialog",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inventory_rounded,
                            color: Color(0xFF2a86c9)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item == null
                                  ? "New Stock Request"
                                  : "Edit Stock Request",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A)),
                            ),
                            Text(
                              item == null
                                  ? "Create a new material requisition"
                                  : "Update requisition details",
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF94A3B8)),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isSmall = constraints.maxWidth < 600;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Requisition Details",
                                Icons.info_outline_rounded),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                item != null
                                    ? Expanded(
                                        child: _buildFormField(
                                          label: "Request ID",
                                          child: _buildValueField(
                                              requestId, Icons.numbers_rounded,
                                              isGray: true),
                                        ),
                                      )
                                    : SizedBox(),
                                item != null
                                    ? const SizedBox(width: 16)
                                    : SizedBox(),
                                Expanded(
                                  child: _buildFormField(
                                    label: "Required Date*",
                                    child: _buildClickableField(
                                      requiredDate != null
                                          ? DateFormat('dd MMM yyyy')
                                              .format(requiredDate!)
                                          : "Select Date",
                                      Icons.calendar_today_rounded,
                                      () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              requiredDate ?? DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null)
                                          setDialogState(
                                              () => requiredDate = date);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSectionHeader(
                                "Product Information", Icons.category_outlined),
                            const SizedBox(height: 16),
                            _buildFormField(
                              label: "Product*",
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildClickableField(
                                      productName ?? "Select Material",
                                      Icons.hardware_rounded,
                                      () => _showItemPicker(
                                          "Product",
                                          _products
                                              .map((p) => p.materialName ?? "")
                                              .toList(), (index) {
                                        setDialogState(() {
                                          productId = _products[index].materialId;
                                          productName = _products[index].materialName;
                                        });
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        var res = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SimpleBarcodeScannerPage(),
                                          ),
                                        );
                                        if (res is String && res != '-1') {
                                          Common.showProgressDialog(context, "Fetching product...");
                                          final productRes = await HttpService.getQrcodeproductDetails(res);
                                          Navigator.pop(context);
                                          if (productRes != null && productRes.data != null) {
                                            setDialogState(() {
                                              productId = productRes.data!.id;
                                              productName = productRes.data!.productName;
                                            });
                                          } else {
                                            Common.toastMessaage("Product not found", Colors.red);
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2a86c9)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    label: "Quantity*",
                                    child: _buildInputField(qtyController,
                                        "0.00", Icons.add_shopping_cart_rounded,
                                        keyboardType: TextInputType.number),
                                  ),
                                ),
                                if (!isSmall) const SizedBox(width: 16),
                                if (!isSmall)
                                  Expanded(
                                    child: _buildFormField(
                                      label: "Status",
                                      child: _buildClickableField(
                                          status, Icons.verified_user_outlined,
                                          () {
                                        _showItemPicker("Status", [
                                          "Pending",
                                          "Approved",
                                          "Rejected"
                                        ], (index) {
                                          setDialogState(() => status = [
                                                "Pending",
                                                "Approved",
                                                "Rejected"
                                              ][index]);
                                        });
                                      }),
                                    ),
                                  ),
                              ],
                            ),
                            if (isSmall) ...[
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: "Status",
                                child: _buildClickableField(
                                    status, Icons.verified_user_outlined, () {
                                  _showItemPicker("Status", [
                                    "Pending",
                                    "Approved",
                                    "Rejected"
                                  ], (index) {
                                    setDialogState(() => status = [
                                          "Pending",
                                          "Approved",
                                          "Rejected"
                                        ][index]);
                                  });
                                }),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // Section 3: Priority
                            _buildLabel("Request Priority"),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  ["High", "Medium", "Low", "Normal"].map((p) {
                                bool isSelected = priority == p;
                                Color pColor = p == "High"
                                    ? Colors.red
                                    : p == "Medium"
                                        ? Colors.orange
                                        : p == "Low"
                                            ? Colors.green
                                            : const Color(0xFF2a86c9);
                                return ChoiceChip(
                                  label: Text(p),
                                  selected: isSelected,
                                  onSelected: (val) =>
                                      setDialogState(() => priority = p),
                                  selectedColor: pColor.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? pColor
                                          : const Color(0xFF64748B),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                  side: BorderSide(
                                      color: isSelected
                                          ? pColor
                                          : const Color(0xFFE2E8F0)),
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                            // Section 4: Location & Person
                            _buildSectionHeader("Source & Logistics",
                                Icons.location_on_outlined),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    label: "Stock Location",
                                    child: _buildClickableField(
                                        locationName ?? "Select Location",
                                        Icons.store_rounded, () {
                                      _showItemPicker(
                                          "Location",
                                          _locations
                                              .map((l) => l.locationName)
                                              .toList(), (index) {
                                        setDialogState(() {
                                          locationId = _locations[index].id;
                                          locationName =
                                              _locations[index].locationName;
                                        });
                                      });
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField(
                                    label: "Requested By",
                                    child: _buildInputField(
                                        requestedByController,
                                        "Your Name",
                                        Icons.person_outline_rounded,
                                        readOnly: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildFormField(
                              label: "Remark / Notes",
                              child: TextField(
                                controller: remarkController,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "Add any special instructions...",
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 13),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF2a86c9),
                                          width: 1.5)),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: const Text("Discard",
                              style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (productId == null ||
                                qtyController.text.isEmpty ||
                                requiredDate == null) {
                              Common.toastMessaage(
                                  "Please fill required fields", Colors.red);
                              return;
                            }
                            Navigator.pop(dialogContext);
                            Common.showProgressDialog(context,
                                item == null ? "Creating..." : "Updating...");
                            Navigator.pop(dialogContext);
                            final body = {
                              if (item != null) "id": item.id,
                              "product_id": productId,
                              "quantity": qtyController.text,
                              "required_date": DateFormat('yyyy-MM-dd')
                                  .format(requiredDate!),
                              "priority": priority,
                              "status": status,
                              "remark": remarkController.text,
                              "location_id": locationId,
                              "requested_by": requestedByController.text,
                            };

                            try {
                              final response = item == null
                                  ? await HttpService.postStockRequest(body)
                                  : await HttpService.updateStockRequest(body);

                              if (context.mounted) {
                                Navigator.pop(context);
                              }

                              if (response != null && response.status == true) {
                                Common.toastMessaage(
                                    item == null
                                        ? "Request created successfully"
                                        : "Request updated successfully",
                                    Colors.green);
                                _fetchRequests();
                              } else {
                                Common.toastMessaage(
                                    response?.message ?? "Something went wrong",
                                    Colors.red);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              Common.toastMessaage("Error: $e", Colors.red);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a86c9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                              item == null ? "Submit Request" : "Save Changes",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF334155)));
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildValueField(String value, IconData icon, {bool isGray = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isGray ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isGray
                      ? const Color(0xFF64748B)
                      : const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildClickableField(String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2a86c9)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            const Icon(Icons.expand_more_rounded,
                size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType, bool readOnly = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: readOnly
                      ? const Color(0xFF64748B)
                      : const Color(0xFF0F172A)),
              decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                  border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemPicker(
      String title, List<String> items, Function(int) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("Select $title",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(items[index],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    onSelect(index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<MaterialData> products;
  final Function(DateTime?, DateTime?, String?, String?) onApply;
  final VoidCallback onReset;
  final DateTime? initialFrom;
  final DateTime? initialTo;
  final String? initialProductId;
  final String? initialProductName;

  const _FilterBottomSheet({
    required this.products,
    required this.onApply,
    required this.onReset,
    this.initialFrom,
    this.initialTo,
    this.initialProductId,
    this.initialProductName,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  DateTime? _from;
  DateTime? _to;
  String? _productId;
  String? _productName;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
    _productId = widget.initialProductId;
    _productName = widget.initialProductName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filters",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Date Range",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  "From Date",
                  _from != null
                      ? DateFormat('dd MMM yyyy').format(_from!)
                      : "Select",
                  () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _from ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _from = date);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  "To Date",
                  _to != null
                      ? DateFormat('dd MMM yyyy').format(_to!)
                      : "Select",
                  () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _to ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _to = date);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Product",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showProductPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_productName ?? "Select Product",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _productName == null
                              ? Colors.grey[400]
                              : const Color(0xFF1E293B))),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Reset",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_from, _to, _productId, _productName);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("Apply Filters",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductPicker() {
    final products = widget.products;
    print("Products count: ${products.length}");
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No products available")),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                "Select Product",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ListTile(
                      title: Text(
                        product.materialName ?? "Unnamed Product",
                      ),
                      onTap: () {
                        setState(() {
                          _productId = product.materialId;
                          _productName = product.materialName;
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
      ),
    );
  }

  Widget _buildDatePicker(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }
}
