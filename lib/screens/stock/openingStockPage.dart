import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/getOpeningModel.dart' as history;
import 'package:login2/models/rental/rentalLocationModel.dart';
import 'package:login2/models/stock/opening_stock_model.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:login2/screens/product_mannagement/product_view.dart';
import 'package:login2/service/service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class OpeningStockPage extends StatefulWidget {
  const OpeningStockPage({super.key});

  @override
  State<OpeningStockPage> createState() => _OpeningStockPageState();
}

class _OpeningStockPageState extends State<OpeningStockPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isHistoryLoading = true;

  // Form State
  DateTime _selectedDate = DateTime.now();
  String? _selectedLocationId;
  String? _selectedLocationName;
  List<OpeningStockItem> _pendingItems = [];

  // Data Lists
  List<MaterialData> _products = [];
  List<RetailLocation> _locations = [];
  List<history.OpeningStockData> _historyItems = [];
  List<history.OpeningStockData> _filteredHistory = [];

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // History Filters
  String? _historyProductId;
  String? _historyProductName;
  String? _historyLocationId;
  String? _historyLocationName;

@override
void initState() {
  super.initState();

  _tabController = TabController(
    length: 1,
    vsync: this,
  );

  _loadInitialData();
  _loadHistory();
  _searchController.addListener(_filterHistory);
}

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final productsResponse = await HttpService.getMaterials();
      final locationsResponse = await HttpService.getRentalLocation();

      setState(() {
        if (productsResponse != null && productsResponse.data != null) {
          _products = productsResponse.data!;
        }
        if (locationsResponse != null && locationsResponse.data != null) {
          _locations = locationsResponse.data!;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading initial data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isHistoryLoading = true);
    try {
      final response = await HttpService.getOpeningStockList(
        productId: _historyProductId,
        locationId: _historyLocationId,
      );
      setState(() {
        if (response != null && response.status) {
          _historyItems = response.data;
          _filteredHistory = response.data;
        } else {
          _historyItems = [];
          _filteredHistory = [];
        }
        _isHistoryLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
      setState(() => _isHistoryLoading = false);
    }
  }

  void _filterHistory() {
    setState(() {
      _filteredHistory = _historyItems.where((item) {
        final query = _searchController.text.toLowerCase();
        return item.materialName.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query) ||
            item.staffName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addItemToPendingList(MaterialData product) {
    if (_qtyController.text.isEmpty ||
        int.tryParse(_qtyController.text) == null) {
      Common.toastMessaage("Enter valid quantity", Colors.red);
      return;
    }
    if (_priceController.text.isEmpty ||
        double.tryParse(_priceController.text) == null) {
      Common.toastMessaage("Enter valid price", Colors.red);
      return;
    }

    setState(() {
      int existingIndex = _pendingItems
          .indexWhere((item) => item.productId == product.materialId);
      if (existingIndex != -1) {
        _pendingItems[existingIndex].quantity += int.parse(_qtyController.text);
      } else {
        _pendingItems.add(OpeningStockItem(
          productId: product.materialId ?? "",
          productName: product.materialName ?? "",
          unit: product.unitName ?? "Nos",
          quantity: int.parse(_qtyController.text),
          unitPrice: double.parse(_priceController.text),
          description: _descController.text,
        ));
      }
      _qtyController.clear();
      _priceController.clear();
      _descController.clear();
    });
    Common.toastMessaage("Added to pending list", Colors.blue);
  }

  void _submitBulkOpeningStock() async {
    if (_pendingItems.isEmpty) {
      Common.toastMessaage("Add items first", Colors.red);
      return;
    }
    // if (_selectedLocationId == null) {
    //   Common.toastMessaage("Select location", Colors.red);
    //   return;
    // }

    Common.showProgressDialog(context, "Submitting Opening Stock...");

    List<Map<String, dynamic>> productsJson = _pendingItems
        .map((item) => {
              "product_id": item.productId,
              "product_name": item.productName,
              "quantity": item.quantity.toString(),
              "unit_price": item.unitPrice.toString(),
              "unit": item.unit,
              "description": item.description,
            })
        .toList();
    final response = await HttpService.postOpeningStocks(
        DateFormat('yyyy-MM-dd').format(_selectedDate),
        _selectedLocationId ?? "",
        productsJson);
    Navigator.pop(context);
    if (response != null && response.status) {
      Common.toastMessaage("Opening stock added successfully", Colors.green);
      setState(() {
        _pendingItems.clear();
        _selectedLocationId = null;
        _selectedLocationName = null;
      });
      _tabController.animateTo(0);
      _loadHistory();
    } else {
      Common.toastMessaage(
          response?.message ?? "Failed to add opening stock", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Opening Stock',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        // bottom: TabBar(
        //   controller: _tabController,
        //   indicatorColor: Colors.white,
        //   indicatorWeight: 3,
        //   labelColor: Colors.white,
        //   unselectedLabelColor: Colors.white.withOpacity(0.7),
        //   labelStyle:
        //       const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        //   tabs: const [
        //     Tab(text: ''),
        //   //  Tab(text: 'Add New'),
        //   ],
        // ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
        //  _buildAddTab(),
        ],
      ),
    );
  }

  // --- HISTORY TAB ---
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: Column(
        children: [
          _buildHistoryHeader(),
          Expanded(
            child: _isHistoryLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredHistory.length,
                        itemBuilder: (context, index) =>
                            _buildHistoryCard(_filteredHistory[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStock(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Are you sure you want to delete this opening stock entry?"),
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
      final response = await HttpService.deleteOpenStock(id);
      Navigator.pop(context); // Close dialog

      if (response != null && response.status == true) {
        Common.toastMessaage("Deleted successfully", Colors.green);
        _loadHistory();
      } else {
        Common.toastMessaage(response?.message ?? "Delete failed", Colors.red);
      }
    }
  }

  Future<void> _showEditDialog(history.OpeningStockData item) async {
    Common.showProgressDialog(context, "Fetching details...");
    final editDataResponse =
        await HttpService.getOpenStockForEdit(item.stockOpeningItemId);
    Navigator.pop(context); // Close progress dialog

    if (editDataResponse == null ||
        editDataResponse.status != true ||
        editDataResponse.data == null) {
      Common.toastMessaage("Failed to fetch details", Colors.red);
      return;
    }

    final data = editDataResponse.data!;

    // Setup controllers with current values
    final TextEditingController editQtyController =
        TextEditingController(text: data.quantity);
    final TextEditingController editPriceController =
        TextEditingController(text: data.unitPrice);
    final TextEditingController editUnitController =
        TextEditingController(text: data.unit);

    String? selectedProductId = data.materialId;
    String? selectedProductName = data.materialName;

    // Find initial location
    String? selectedLocId;
    final loc = _locations.firstWhere((l) => l.locationName == item.location,
        orElse: () => _locations.isNotEmpty
            ? _locations.first
            : RetailLocation(id: "", locationName: ""));
    selectedLocId = loc.id;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => Container(
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Opening Stock",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Product Name
                const Text("Product Name",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF334155))),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25))),
                      builder: (context) =>
                          StatefulBuilder(builder: (context, setModalState) {
                        TextEditingController localSearch =
                            TextEditingController();
                        List<MaterialData> filteredProducts =
                            List.from(_products);
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2))),
                              const SizedBox(height: 20),
                              const Text("Select Product",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              TextField(
                                controller: localSearch,
                                decoration: InputDecoration(
                                  hintText: "Search products...",
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (val) {
                                  setModalState(() {
                                    filteredProducts = _products
                                        .where((p) => (p.materialName ?? "")
                                            .toLowerCase()
                                            .contains(val.toLowerCase()))
                                        .toList();
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final p = filteredProducts[index];
                                    return ListTile(
                                      title: Text(p.materialName ?? "Unknown"),
                                      onTap: () {
                                        setDialogState(() {
                                          selectedProductId = p.materialId;
                                          selectedProductName = p.materialName;
                                          editUnitController.text =
                                              p.unitName ?? "";
                                          editPriceController.text =
                                              p.unitPrice ?? "0";
                                        });
                                        Navigator.pop(dialogContext);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedProductName ?? "Select Product",
                            style: const TextStyle(fontSize: 16)),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Unit
                const Text("Unit",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF334155))),
                const SizedBox(height: 8),
                TextField(
                  controller: editUnitController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity
                const Text("Quantity",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF334155))),
                const SizedBox(height: 8),
                TextField(
                  controller: editQtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 16),

                // Unit Price
                const Text("Unit Price",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF334155))),
                const SizedBox(height: 8),
                TextField(
                  controller: editPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text("Close",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedProductId == null) {
                            Common.toastMessaage("Select product", Colors.red);
                            return;
                          }
                          
                          Navigator.pop(dialogContext); 
                          Common.showProgressDialog(context, "Updating...");
                          Navigator.pop(dialogContext);
                          try {
                            final updateResponse =
                                await HttpService.updateOpeningStock(
                              id: data.stockOpeningItemId ?? "",
                              date: item.date,
                              locationId: selectedLocId!,
                              productId: selectedProductId!,
                              quantity: editQtyController.text,
                              unitPrice: editPriceController.text,
                              unit: editUnitController.text,
                              description: "",
                            );

                           

                            if (updateResponse != null && updateResponse.status == true) {
                              Common.toastMessaage(
                                  "Updated successfully", Colors.green);
                              _loadHistory();
                            } else {
                              Common.toastMessaage(
                                  updateResponse?.message ?? "Update failed",
                                  Colors.red);
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                            debugPrint("Update error: $e");
                            Common.toastMessaage("Error: $e", Colors.red);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F51B5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: const Text("Submit",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
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

  Widget _buildDialogClickableField(
      {required String label,
      required String value,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                hintText: "Search by product, location...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHistoryFilterChip(
                  label: _historyProductName ?? "All Products",
                  icon: Icons.inventory_2_outlined,
                  onTap: _showHistoryProductPicker,
                  onClear: _historyProductId == null
                      ? null
                      : () {
                          setState(() {
                            _historyProductId = null;
                            _historyProductName = null;
                          });
                          _loadHistory();
                        },
                ),
              ),
           //   const SizedBox(width: 8),
              // Expanded(
              //   child: _buildHistoryFilterChip(
              //     label: _historyLocationName ?? "All Locations",
              //     icon: Icons.location_on_outlined,
              //     onTap: _showHistoryLocationPicker,
              //     onClear: _historyLocationId == null
              //         ? null
              //         : () {
              //             setState(() {
              //               _historyLocationId = null;
              //               _historyLocationName = null;
              //             });
              //             _loadHistory();
              //           },
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryFilterChip(
      {required String label,
      required IconData icon,
      required VoidCallback onTap,
      VoidCallback? onClear}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(history.OpeningStockData item) {
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
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductView(
                                      productId: item.materialId,
                                      title: item.materialName,
                                    ),
                                  ),
                                ).then((_) {
                                  // getProductLists();
                                });
                              },
                              child: Text(
                                item.materialName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                color: Colors.grey[400], size: 20),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(item);
                              } else if (value == 'delete') {
                                _deleteStock(item.stockOpeningItemId);
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
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a86c9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "₹${item.totalAmount}",
                              style: const TextStyle(
                                  color: Color(0xFF2a86c9),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          Icons.calendar_today_outlined, "Date", item.date),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on_outlined, "Location",
                          item.location),
                      const Divider(height: 24),
                      Row(
                        children: [
                          _buildMiniStat(
                              "Qty", "${item.quantity} ${item.unit}"),
                          const Spacer(),
                          _buildMiniStat("Price", "₹${item.unitPrice}"),
                          const Spacer(),
                          _buildMiniStat("By", item.staffName, isRight: true),
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

  Widget _buildMiniStat(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
          Text("No opening stock found",
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

  // --- ADD TAB ---
  Widget _buildAddTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormCard(),
          const SizedBox(height: 24),
          if (_pendingItems.isNotEmpty) ...[
            const Text("Pending Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ..._pendingItems
                .asMap()
                .entries
                .map((e) => _buildPendingItemCard(e.value, e.key))
                .toList(),
            const SizedBox(height: 24),
            _buildSubmitSection(),
          ] else
            _buildNoPendingState(),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter Stock Entry",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildClickableField(
                  label: "Date",
                  value: DateFormat('dd MMM yyyy').format(_selectedDate),
                  icon: Icons.calendar_month_outlined,
                  onTap: () => _selectDate(context),
                ),
              ),
              // const SizedBox(width: 12),
              // Expanded(
              //   child: _buildClickableField(
              //     label: "Location",
              //     value: _selectedLocationName ?? "Select",
              //     icon: Icons.store_outlined,
              //     onTap: () => _showLocationPicker(),
              //   ),
              // ),
            ],
          ),
          // const SizedBox(height: 16),
          // _buildClickableField(
          //   label: "Product",
          //   value: "Select a product to add",
          //   icon: Icons.inventory_2_outlined,
          //   onTap: () => _showProductPicker(),
          //   isHighlight: true,
          // ),
          const SizedBox(height: 16),
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      child: _buildClickableField(
        label: "Product",
        value: "Select a product to add",
        icon: Icons.inventory_2_outlined,
        onTap: () => _showProductPicker(),
        isHighlight: true,
      ),
    ),
    const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
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
                                final productData = productRes.data!;
                                final material = MaterialData(
                                  materialId: productData.id,
                                  materialName: productData.productName,
                                  unitName: productData.unitName,
                                  unitPrice: productData.purchaseAmount ?? productData.sellingPrice,
                                  gstPercentage: productData.taxPercent,
                                );
                                _showQuantityDialog(material);
                              } else {
                                Common.toastMessaage("Product not found", Colors.red);
                              }
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2a86c9)),
                        ),
                      ),
    const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a86c9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddProducts(),
                              ),
                            );
                            // if (result == true) {
                            //   await _fetchStockRegister();
                            //   setModalState(() {});
                            // }
                          },
                          icon: const Icon(Icons.add, color: Color(0xFF2a86c9)),
                        ),
                      ),
  ],
),
        ],
      ),
    );
  }

  Widget _buildClickableField(
      {required String label,
      required String value,
      required IconData icon,
      required VoidCallback onTap,
      bool isHighlight = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlight
              ? const Color(0xFF2a86c9).withOpacity(0.05)
              : Colors.white,
          border: Border.all(
              color: isHighlight
                  ? const Color(0xFF2a86c9).withOpacity(0.3)
                  : Colors.grey[200]!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color:
                    isHighlight ? const Color(0xFF2a86c9) : Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHighlight
                              ? const Color(0xFF2a86c9)
                              : Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingItemCard(OpeningStockItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2a86c9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_basket_outlined,
                color: Color(0xFF2a86c9), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${item.quantity} ${item.unit} @ ₹${item.unitPrice}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${item.totalAmount}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF2a86c9))),
              InkWell(
                onTap: () => setState(() => _pendingItems.removeAt(index)),
                child: Text("Remove",
                    style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoPendingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.add_shopping_cart, size: 60, color: Colors.grey[200]),
          const SizedBox(height: 12),
          Text("No items added to pending list",
              style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildSubmitSection() {
    double total = _pendingItems.fold(0, (sum, item) => sum + item.totalAmount);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF2a86c9))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _submitBulkOpeningStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a86c9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text("SUBMIT OPENING STOCK",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOGS & PICKERS ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2a86c9)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _buildPickerSheet(
        title: "Select Location",
        items: _locations.map((l) => l.locationName).toList(),
        onSelect: (index) {
          setState(() {
            _selectedLocationId = _locations[index].id;
            _selectedLocationName = _locations[index].locationName;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showProductPicker() {
    TextEditingController localSearch = TextEditingController();
    List<MaterialData> filteredProducts = List.from(_products);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text("Select Product",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: localSearch,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setModalState(() {
                    filteredProducts = _products
                        .where((p) => (p.materialName ?? "")
                            .toLowerCase()
                            .contains(val.toLowerCase()))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final p = filteredProducts[index];
                    return ListTile(
                      title: Text(p.materialName ?? "Unknown"),
                      subtitle: Text(
                          "Price: ₹${p.unitPrice ?? '0'} | Unit: ${p.unitName ?? '-'}"),
                      trailing: const Icon(Icons.add_circle_outline,
                          color: Color(0xFF2a86c9)),
                      onTap: () {
                        Navigator.pop(context);
                        _showQuantityDialog(p);
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

  void _showQuantityDialog(MaterialData product) {
    _qtyController.clear();
    _priceController.text = product.unitPrice ?? "0";
    _descController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add ${product.materialName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: "Quantity", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Unit Price", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                  labelText: "Description", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addItemToPendingList(product);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a86c9),
                foregroundColor: Colors.white),
            child: const Text("Add to List"),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSheet(
      {required String title,
      required List<String> items,
      required Function(int) onSelect}) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
                onTap: () => onSelect(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryProductPicker() {
    TextEditingController localSearch = TextEditingController();
    List<MaterialData> filteredProducts = List.from(_products);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text("Filter by Product",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: localSearch,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setModalState(() {
                    filteredProducts = _products
                        .where((p) => (p.materialName ?? "")
                            .toLowerCase()
                            .contains(val.toLowerCase()))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final p = filteredProducts[index];
                    return ListTile(
                      title: Text(p.materialName ?? "Unknown"),
                      onTap: () {
                        setState(() {
                          _historyProductId = p.materialId;
                          _historyProductName = p.materialName;
                        });
                        Navigator.pop(context);
                        _loadHistory();
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

  void _showHistoryLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _buildPickerSheet(
        title: "Filter by Location",
        items: _locations.map((l) => l.locationName).toList(),
        onSelect: (index) {
          setState(() {
            _historyLocationId = _locations[index].id;
            _historyLocationName = _locations[index].locationName;
          });
          Navigator.pop(context);
          _loadHistory();
        },
      ),
    );
  }
}
