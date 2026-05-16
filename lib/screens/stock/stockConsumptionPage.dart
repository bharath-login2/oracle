import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/materialModel.dart' as mat;
import 'package:login2/models/lead_management/stockCounsumptionListModel.dart';
import 'package:login2/models/lead_management/getMaterialForStockCunsuptionModel.dart';
import 'package:login2/models/rental/rentalLocationModel.dart' as loc;
import 'package:login2/service/service.dart';

class StockConsumptionPage extends StatefulWidget {
  const StockConsumptionPage({super.key});

  @override
  State<StockConsumptionPage> createState() => _StockConsumptionPageState();
}

class _StockConsumptionPageState extends State<StockConsumptionPage> {
  bool _isLoading = true;
  List<ConsumptionData> _consumptionList = [];
  List<ConsumptionData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String? _selectedProductId;
  String? _selectedProductName;
  List<mat.MaterialData> _products = [];
  List<loc.RetailLocation> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchConsumption();
    _searchController.addListener(_filterBySearch);
  }

  Future<void> _loadInitialData() async {
    final prodResponse = await HttpService.getMaterials();
    final locResponse = await HttpService.getRentalLocation();
    if (mounted) {
      setState(() {
        if (prodResponse != null) _products = prodResponse.data ?? [];
        if (locResponse != null) _locations = locResponse.data;
      });
    }
  }

  Future<void> _fetchConsumption() async {
    setState(() => _isLoading = true);
    try {
      final response = await HttpService.getProductStockConsumedList(_selectedProductId ?? "");
      setState(() {
        if (response != null && response.status == true) {
          _consumptionList = response.data;
          _filteredList = List.from(_consumptionList);
        } else {
          _consumptionList = [];
          _filteredList = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching consumption: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterBySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _consumptionList.where((item) {
        return item.materialName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Stock Consumption',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchConsumption,
                    child: _filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) =>
                                _buildConsumptionCard(_filteredList[index]),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConsumptionPage(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("ADD CONSUMPTION",
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
                hintText: "Search materials...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showProductPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 18, color: Color(0xFF2a86c9)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedProductName ?? "All Products",
                        style: TextStyle(
                          color: _selectedProductName == null
                              ? Colors.grey[400]
                              : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_selectedProductId != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProductId = null;
                            _selectedProductName = null;
                          });
                          _fetchConsumption();
                        },
                        child: const Icon(Icons.close, size: 18, color: Colors.red),
                      )
                    else
                      const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionCard(ConsumptionData item) {
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
                    item.materialName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _deleteConsumption(item.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoTag(Icons.calendar_today, item.date, Colors.blue),
                const SizedBox(width: 10),
                _buildInfoTag(Icons.straighten, item.unit, Colors.orange),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn("Consumed Stock QTY", item.quantity, Colors.green),
                _buildStatColumn("Unit Price", "₹${item.unitPrice}", Colors.blue),
                _buildStatColumn("Consumed Stock Price", "₹${item.totalAmount}", const Color(0xFF2a86c9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: color)),
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
          Text("No consumption data found",
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return ListTile(
                      title: Text(p.materialName ?? ""),
                      onTap: () {
                        setState(() {
                          _selectedProductId = p.materialId;
                          _selectedProductName = p.materialName;
                        });
                        Navigator.pop(context);
                        _fetchConsumption();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteConsumption(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Consumption"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      Common.showProgressDialog(context, "Deleting...");
      final response = await HttpService.deleteStockConsumed(id);
      Navigator.pop(context);

      if (response != null && response.status == true) {
        Common.toastMessaage("Deleted successfully", Colors.green);
        _fetchConsumption();
      } else {
        Common.toastMessaage(response?.message ?? "Delete failed", Colors.red);
      }
    }
  }

  void _showAddConsumptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStockConsumptionPage(
          locations: _locations,
          allProducts: _products,
        ),
      ),
    ).then((value) {
      if (value == true) _fetchConsumption();
    });
  }
}

class AddStockConsumptionPage extends StatefulWidget {
  final List<loc.RetailLocation> locations;
  final List<mat.MaterialData> allProducts;

  const AddStockConsumptionPage({
    super.key,
    required this.locations,
    required this.allProducts,
  });

  @override
  State<AddStockConsumptionPage> createState() => _AddStockConsumptionPageState();
}

class _AddStockConsumptionPageState extends State<AddStockConsumptionPage> {
  DateTime _consumedDate = DateTime.now();
  String? _selectedProductId;
  String? _selectedProductName;
  String? _selectedLocationId;
  String? _selectedLocationName;
  
  List<ConsumptionMaterialData> _materials = [];
  Map<String, double> _consumedQtys = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.locations.isNotEmpty) {
      _selectedLocationId = widget.locations.first.id;
      _selectedLocationName = widget.locations.first.locationName;
    }
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_consumedDate);
      final response = await HttpService.getMaterialForConsumption(
        dateStr,
        _selectedProductId ?? "",
        _selectedLocationId ?? "",
      );
      if (mounted) {
        setState(() {
          _materials = response?.data ?? [];
          // Keep existing quantities if still in the list
          final newQtys = <String, double>{};
          for (var m in _materials) {
            newQtys[m.id] = _consumedQtys[m.id] ?? 0.0;
          }
          _consumedQtys = newQtys;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching materials for consumption: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _grandTotal {
    double total = 0;
    for (var m in _materials) {
      final qty = _consumedQtys[m.id] ?? 0.0;
      final price = double.tryParse(m.unitPrice) ?? 0.0;
      total += qty * price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Stock Consumption',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2a86c9),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _materials.isEmpty
                    ? _buildEmptyState()
                    : _buildMaterialsList(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Consumed Date *",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _consumedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _consumedDate = date);
                          _fetchMaterials();
                        }
                      },
                      child: _buildFilterBox(
                        DateFormat('dd-MM-yyyy').format(_consumedDate),
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Product",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _showProductPicker,
                      child: _buildFilterBox(
                        _selectedProductName ?? "---All Product---",
                        Icons.inventory_2_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // if (widget.locations.length > 1) ...[
          //   const SizedBox(height: 12),
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text("Location",
          //           style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          //       const SizedBox(height: 6),
          //       GestureDetector(
          //         onTap: _showLocationPicker,
          //         child: _buildFilterBox(
          //           _selectedLocationName ?? "Select Location",
          //           Icons.location_on_outlined,
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _buildFilterBox(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2a86c9)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMaterialsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final m = _materials[index];
        return _buildMaterialCard(m, index + 1);
      },
    );
  }

  Widget _buildMaterialCard(ConsumptionMaterialData m, int siNo) {
    final qty = _consumedQtys[m.id] ?? 0.0;
    final price = double.tryParse(m.unitPrice) ?? 0.0;
    final amount = qty * price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                  child: Text("$siNo", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(m.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _buildCardInfo("Unit", m.unitName),
                _buildCardInfo("Unit Price", "₹${m.unitPrice}"),
                _buildCardInfo("Current Stock", m.currentStock),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Consumed Qty",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (qty > 0) {
                                  setState(() => _consumedQtys[m.id] = qty - 1);
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                                onChanged: (val) {
                                  setState(() => _consumedQtys[m.id] = double.tryParse(val) ?? 0.0);
                                },
                                controller: TextEditingController(text: qty == 0 ? "0" : qty.toStringAsFixed(0))
                                  ..selection = TextSelection.fromPosition(TextPosition(offset: (qty == 0 ? "0" : qty.toStringAsFixed(0)).length)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                setState(() => _consumedQtys[m.id] = qty + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Amount",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("₹${amount.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2a86c9))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Grand Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹${_grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2a86c9))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Close"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitConsumption,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(
                title: const Text("---All Product---"),
                onTap: () {
                  setState(() {
                    _selectedProductId = null;
                    _selectedProductName = null;
                  });
                  Navigator.pop(context);
                  _fetchMaterials();
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.allProducts.length,
                  itemBuilder: (context, index) {
                    final p = widget.allProducts[index];
                    return ListTile(
                      title: Text(p.materialName ?? ""),
                      onTap: () {
                        setState(() {
                          _selectedProductId = p.materialId;
                          _selectedProductName = p.materialName;
                        });
                        Navigator.pop(context);
                        _fetchMaterials();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.locations.length,
                  itemBuilder: (context, index) {
                    final l = widget.locations[index];
                    return ListTile(
                      title: Text(l.locationName),
                      onTap: () {
                        setState(() {
                          _selectedLocationId = l.id;
                          _selectedLocationName = l.locationName;
                        });
                        Navigator.pop(context);
                        _fetchMaterials();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitConsumption() async {
    final itemsToSubmit = <Map<String, dynamic>>[];
    for (var m in _materials) {
      final qty = _consumedQtys[m.id] ?? 0.0;
      if (qty > 0) {
        itemsToSubmit.add({
          "product_id": m.id,
          "quantity": qty.toString(),
          "unit_price": m.unitPrice,
          "unit": m.unitName,
        });
      }
    }

    if (itemsToSubmit.isEmpty) {
      Common.toastMessaage("Please enter quantity for at least one item", Colors.orange);
      return;
    }

    if (_selectedLocationId == null) {
      Common.toastMessaage("Please select a location", Colors.orange);
      return;
    }

    Common.showProgressDialog(context, "Saving Consumption...");
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_consumedDate);
      final response = await HttpService.addStockConsumption(
        date: dateStr,
        locationId: _selectedLocationId!,
        items: itemsToSubmit,
      );

      if (mounted) Navigator.pop(context); // Close progress dialog

      if (response != null && response.status == true) {
        Common.toastMessaage("Stock consumption saved successfully", Colors.green);
        Navigator.pop(context, true); // Go back with success
      } else {
        Common.toastMessaage(response?.message ?? "Failed to save consumption", Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No materials available for consumption", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }
}
