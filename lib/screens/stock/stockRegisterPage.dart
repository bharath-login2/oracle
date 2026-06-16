import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getStockRegisterListModel.dart';
import 'package:login2/models/lead_management/productHistoryRental.dart';
import 'package:login2/service/service.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:login2/screens/purchase/purchaseBillPage.dart';
import 'package:login2/screens/product_mannagement/product_view.dart';
import 'package:login2/screens/stock/stockConsumptionPage.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class StockRegisterPage extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final bool showAddDialogOnArrive;

  const StockRegisterPage({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.showAddDialogOnArrive = false,
  });

  @override
  State<StockRegisterPage> createState() => _StockRegisterPageState();
}

class _StockRegisterPageState extends State<StockRegisterPage> {
  bool isLoading = true;
  List<StockRegisterData> materials = [];
  List<StockRegisterData> filteredMaterials = [];
  List<Map<String, dynamic>> pendingStockItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStockRegister();
    if (widget.showAddDialogOnArrive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddStockDialog();
      });
    }
  }

  Future<void> _fetchStockRegister() async {
    setState(() => isLoading = true);
    try {
      final response = await HttpService.getStockRegisterList("0");
      if (response != null && response.status == true) {
        setState(() {
          materials = response.data;
          filteredMaterials = materials;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching stock register: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterMaterials(String query) {
    setState(() {
      filteredMaterials = materials
          .where((m) =>
              (m.materialName).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _submitAllStock() async {
    if (pendingStockItems.isEmpty) return;
    Common.showProgressDialog(context, "Updating stock...");
    try {
      final response = await HttpService.postStocks(pendingStockItems);
      Navigator.pop(context);

      if (response != null && response.status == true) {
        Common.toastMessaage("All stock added successfully", Colors.green);
        setState(() {
          pendingStockItems.clear();
        });
        _fetchStockRegister();
      } else {
        Common.toastMessaage(
            response?.message ?? "Failed to add stock", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2a86c9),
        title: const Text('Stock Register',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseBillPage(
                      token: widget.token,
                      name: widget.name,
                      userId: widget.userId,
                      showAddDialogOnArrive: true,
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Purchase Bill',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: "MontserratMedium",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndAdd(),
          if (pendingStockItems.isNotEmpty) _buildPendingList(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMaterials.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchStockRegister,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: filteredMaterials.length,
                          itemBuilder: (context, index) {
                            final item = filteredMaterials[index];
                            return _buildStockCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: pendingStockItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _submitAllStock,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text('Submit ${pendingStockItems.length} Items to Stock',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
    );
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      int currentQty =
          int.tryParse(pendingStockItems[index]['quantity'].toString()) ?? 0;
      int newQty = currentQty + delta;
      if (newQty > 0) {
        pendingStockItems[index]['quantity'] = newQty.toString();
      } else {
        pendingStockItems.removeAt(index);
      }
    });
  }

  Widget _buildPendingList() {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Pending Stock",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${pendingStockItems.length}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => setState(() => pendingStockItems.clear()),
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.red, size: 18),
                  label: const Text("Clear",
                      style: TextStyle(color: Colors.red, fontSize: 13)),
                )
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: pendingStockItems.length,
              itemBuilder: (context, index) {
                final item = pendingStockItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['product_name'] ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Unit: ${item['unit']}",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildQtyBtn(
                                Icons.remove, () => _updateQuantity(index, -1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "${item['quantity']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            _buildQtyBtn(
                                Icons.add, () => _updateQuantity(index, 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: Colors.blue),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No stock items found",
              style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSearchAndAdd() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Stock...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _filterMaterials,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _showAddStockDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(StockRegisterData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2a86c9).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section with Gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2a86c9).withOpacity(0.08),
                  const Color(0xFF2a86c9).withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child:Row(
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
                      ).then((_) => _fetchStockRegister());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.materialName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildIconButton(
                      icon: Icons.history_rounded,
                      onPressed: () => _showRentalTimeline(item),
                      tooltip: "View History",
                    ),
                  ],
                ),
              ],
            )
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
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
                            ).then((_) => _fetchStockRegister());
                          },
                          child: _buildStockStat(
                            'Current',
                            item.currentQty,
                            const Color(0xFF10B981),
                            Icons.check_circle,
                          ),
                        ),
                      ),
                      _buildStatDivider(),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseBillPage(
                                  token: widget.token,
                                  name: widget.name,
                                  userId: widget.userId,
                                  initialSearchQuery: item.materialName,
                                ),
                              ),
                            );
                          },
                          child: _buildStockStat(
                            'Purchased',
                            item.purchasedQty,
                            const Color(0xFF3B82F6),
                            Icons.shopping_cart,
                          ),
                        ),
                      ),
                      _buildStatDivider(),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockConsumptionPage(
                                  initialProductId: item.materialId,
                                  initialProductName: item.materialName,
                                ),
                              ),
                            );
                          },
                          child: _buildStockStat(
                            'Consumed',
                            item.consumedQty,
                            const Color(0xFFF59E0B),
                            Icons.analytics,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      required VoidCallback onPressed,
      required String tooltip}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF2a86c9), size: 20),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFE2E8F0),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildStockStat(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  void _showRentalTimeline(StockRegisterData item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFD),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Stock History",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.materialName,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: FutureBuilder<ProductHistoryRentalModel?>(
                  future: HttpService.getStockHistoryRental(item.materialId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.status == false) {
                      return _buildTimelineError();
                    }
                    final history = snapshot.data!.data;
                    if (history.isEmpty) {
                      return _buildTimelineEmpty();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineItem(
                            history[index], index == history.length - 1);
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

  Widget _buildTimelineItem(ProductHistoryData hist, bool isLast) {
    Color actionColor = Colors.blue;
    IconData actionIcon = Icons.info_outline;

    switch (hist.actionType.toLowerCase()) {
      case 'issue':
      case 'issued':
        actionColor = Colors.orange;
        actionIcon = Icons.outbox_outlined;
        break;
      case 'return':
      case 'returned':
        actionColor = Colors.green;
        actionIcon = Icons.move_to_inbox_outlined;
        break;
      case 'purchase':
      case 'added':
        actionColor = Colors.blue;
        actionIcon = Icons.add_shopping_cart;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: actionColor.withOpacity(0.2), width: 2),
                ),
                child: Icon(actionIcon, color: actionColor, size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hist.actionType.toUpperCase(),
                            style: TextStyle(
                              color: actionColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            _formatDate(hist.createdAt),
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (hist.customerName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            hist.customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      if (hist.locationName.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              hist.locationName,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (int.parse(hist.issuedQuantity) > 0)
                            _buildHistoryBadge("Issued: ${hist.issuedQuantity}",
                                Colors.orange),
                          if (int.parse(hist.returnedQuantity) > 0)
                            _buildHistoryBadge(
                                "Returned: ${hist.returnedQuantity}",
                                Colors.green),
                          if (hist.addedQuantity.isNotEmpty &&
                              int.parse(hist.addedQuantity) > 0)
                            _buildHistoryBadge(
                                "Added: ${hist.addedQuantity}", Colors.blue),
                                  _buildHistoryBadge("Current: ${hist.currentStock}", const Color.fromARGB(255, 33, 243, 121)),
                           _buildHistoryBadge("By: ${hist.companyName}", const Color.fromARGB(255, 26, 117, 145)),
                        ],
                      ),
                      if (hist.rentNo.isNotEmpty || hist.invoiceNo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Ref: ${hist.rentNo.isNotEmpty ? hist.rentNo : hist.invoiceNo}",
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildHistoryBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTimelineEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No history found for this product",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTimelineError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[100]),
          const SizedBox(height: 16),
          Text("Failed to load history",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }


  void _showAddStockDialog() {
  StockRegisterData? selectedMaterial;
  int quantityValue = 1; // Default quantity
  TextEditingController qtyController = TextEditingController(text: "1");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add to Stock List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Select Product',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showSearchProductDialog(context, materials, (val) {
                            setModalState(() {
                              selectedMaterial = val;
                            });
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedMaterial != null
                                      ? selectedMaterial!.materialName
                                      : 'Choose a product',
                                  style: TextStyle(
                                    color: selectedMaterial != null ? Colors.black87 : Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
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
                              int existingIndex = materials.indexWhere((m) => m.materialId == productData.id);
                              if (existingIndex != -1) {
                                setModalState(() {
                                  selectedMaterial = materials[existingIndex];
                                });
                              } else {
                                Common.toastMessaage("Product not found in register", Colors.red);
                              }
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
                          if (result == true) {
                            await _fetchStockRegister();
                            setModalState(() {});
                          }
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF2a86c9)),
                      ),
                    ),
                  ],
                ),
                if (selectedMaterial != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a86c9).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF2a86c9).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildModalInfoRow(
                            'Product Name', selectedMaterial!.materialName),
                        const SizedBox(height: 8),
                        _buildModalInfoRow(
                            'Current Stock', selectedMaterial!.currentQty),
                        const SizedBox(height: 8),
                        _buildModalInfoRow('Unit', selectedMaterial!.unit),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Quantity to Add',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Quantity selector with +/- buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        // Minus Button
                        InkWell(
                          onTap: () {
                            if (quantityValue > 1) {
                              setModalState(() {
                                quantityValue--;
                                qtyController.text = quantityValue.toString();
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: quantityValue > 1 
                                  ? const Color(0xFF2a86c9).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 20,
                              color: quantityValue > 1 
                                  ? const Color(0xFF2a86c9)
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                        
                        // Quantity Display
                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                int? newValue = int.tryParse(value);
                                if (newValue != null && newValue > 0) {
                                  setModalState(() {
                                    quantityValue = newValue;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        
                        // Plus Button
                        InkWell(
                          onTap: () {
                            setModalState(() {
                              quantityValue++;
                              qtyController.text = quantityValue.toString();
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a86c9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF2a86c9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedMaterial == null
                        ? null
                        : () {
                            if (qtyController.text.isEmpty || quantityValue <= 0) {
                              Common.toastMessaage(
                                  "Please enter a valid quantity", Colors.red);
                              return;
                            }

                            setState(() {
                              int existingIndex =
                                  pendingStockItems.indexWhere((item) =>
                                      item['product_id'] ==
                                      selectedMaterial!.materialId);

                              if (existingIndex != -1) {
                                int oldQty = int.tryParse(
                                        pendingStockItems[existingIndex]
                                                ['quantity']
                                            .toString()) ??
                                    0;
                                pendingStockItems[existingIndex]['quantity'] =
                                    (oldQty + quantityValue).toString();
                              } else {
                                pendingStockItems.add({
                                  "product_id": selectedMaterial!.materialId,
                                  "product_name":
                                      selectedMaterial!.materialName,
                                  "quantity": quantityValue.toString(),
                                  "unit_price": selectedMaterial!.unitPrice,
                                  "unit": selectedMaterial!.unit,
                                });
                              }
                            });

                            Navigator.pop(context);
                            Common.toastMessaage(
                                "Added ${quantityValue} ${selectedMaterial!.unit} to list", 
                                Colors.blue);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a86c9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      selectedMaterial != null 
                          ? 'Add ${quantityValue} ${selectedMaterial!.unit} to List'
                          : 'Add to List',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
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

  // void _showAddStockDialog() {
  //   StockRegisterData? selectedMaterial;
  //   TextEditingController qtyController = TextEditingController();

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           return Padding(
  //             padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom,
  //               left: 20,
  //               right: 20,
  //               top: 20,
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       'Add to Stock List',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 20),
  //                 const Text('Select Product',
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: InkWell(
  //                         onTap: () {
  //                           _showSearchProductDialog(context, materials, (val) {
  //                             setModalState(() {
  //                               selectedMaterial = val;
  //                             });
  //                           });
  //                         },
  //                         borderRadius: BorderRadius.circular(12),
  //                         child: Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
  //                           decoration: BoxDecoration(
  //                             border: Border.all(color: Colors.grey.shade400),
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Expanded(
  //                                 child: Text(
  //                                   selectedMaterial != null
  //                                       ? selectedMaterial!.materialName
  //                                       : 'Choose a product',
  //                                   style: TextStyle(
  //                                     color: selectedMaterial != null ? Colors.black87 : Colors.grey.shade600,
  //                                     fontSize: 15,
  //                                   ),
  //                                   maxLines: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                 ),
  //                               ),
  //                               const Icon(Icons.arrow_drop_down, color: Colors.grey),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFF2a86c9).withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: IconButton(
  //                         onPressed: () async {
  //                           var res = await Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const SimpleBarcodeScannerPage(),
  //                             ),
  //                           );
  //                           if (res is String && res != '-1') {
  //                             Common.showProgressDialog(context, "Fetching product...");
  //                             final productRes = await HttpService.getQrcodeproductDetails(res);
  //                             Navigator.pop(context);
  //                             if (productRes != null && productRes.data != null) {
  //                               final productData = productRes.data!;
  //                               int existingIndex = materials.indexWhere((m) => m.materialId == productData.id);
  //                               if (existingIndex != -1) {
  //                                 setModalState(() {
  //                                   selectedMaterial = materials[existingIndex];
  //                                 });
  //                               } else {
  //                                 Common.toastMessaage("Product not found in register", Colors.red);
  //                               }
  //                             } else {
  //                               Common.toastMessaage("Product not found", Colors.red);
  //                             }
  //                           }
  //                         },
  //                         icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2a86c9)),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFF2a86c9).withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: IconButton(
  //                         onPressed: () async {
  //                           final result = await Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const AddProducts(),
  //                             ),
  //                           );
  //                           if (result == true) {
  //                             await _fetchStockRegister();
  //                             setModalState(() {});
  //                           }
  //                         },
  //                         icon: const Icon(Icons.add, color: Color(0xFF2a86c9)),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 if (selectedMaterial != null) ...[
  //                   const SizedBox(height: 20),
  //                   Container(
  //                     padding: const EdgeInsets.all(15),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF2a86c9).withOpacity(0.05),
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                           color: const Color(0xFF2a86c9).withOpacity(0.2)),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         _buildModalInfoRow(
  //                             'Product Name', selectedMaterial!.materialName),
  //                         const SizedBox(height: 8),
  //                         _buildModalInfoRow(
  //                             'Current Stock', selectedMaterial!.currentQty),
  //                         const SizedBox(height: 8),
  //                         _buildModalInfoRow('Unit', selectedMaterial!.unit),
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 20),
  //                   const Text('Quantity to Add',
  //                       style: TextStyle(fontWeight: FontWeight.bold)),
  //                   const SizedBox(height: 8),
  //                   TextField(
  //                     controller: qtyController,
  //                     keyboardType: TextInputType.number,
  //                     decoration: InputDecoration(
  //                       hintText: 'Enter Quantity',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       suffixText: selectedMaterial!.unit,
  //                     ),
  //                   ),
  //                 ],
  //                 const SizedBox(height: 30),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     onPressed: selectedMaterial == null
  //                         ? null
  //                         : () {
  //                             if (qtyController.text.isEmpty) {
  //                               Common.toastMessaage(
  //                                   "Please enter quantity", Colors.red);
  //                               return;
  //                             }

  //                             setState(() {
  //                               int existingIndex =
  //                                   pendingStockItems.indexWhere((item) =>
  //                                       item['product_id'] ==
  //                                       selectedMaterial!.materialId);

  //                               if (existingIndex != -1) {
  //                                 int oldQty = int.tryParse(
  //                                         pendingStockItems[existingIndex]
  //                                                 ['quantity']
  //                                             .toString()) ??
  //                                     0;
  //                                 int addQty =
  //                                     int.tryParse(qtyController.text) ?? 0;
  //                                 pendingStockItems[existingIndex]['quantity'] =
  //                                     (oldQty + addQty).toString();
  //                               } else {
  //                                 pendingStockItems.add({
  //                                   "product_id": selectedMaterial!.materialId,
  //                                   "product_name":
  //                                       selectedMaterial!.materialName,
  //                                   "quantity": qtyController.text,
  //                                   "unit_price": selectedMaterial!.unitPrice,
  //                                   "unit": selectedMaterial!.unit,
  //                                 });
  //                               }
  //                             });

  //                             Navigator.pop(context);
  //                             Common.toastMessaage(
  //                                 "Added to list", Colors.blue);
  //                           },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFF2a86c9),
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(vertical: 15),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     child: const Text('Add to List',
  //                         style: TextStyle(
  //                             fontSize: 16, fontWeight: FontWeight.bold)),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildModalInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showSearchProductDialog(
    BuildContext context,
    List<StockRegisterData> items,
    ValueChanged<StockRegisterData> onSelected,
  ) {
    List<StockRegisterData> searchResults = List.from(items);
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search product...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setStateDialog(() {
                                    searchResults = List.from(items);
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          searchResults = items
                              .where((item) => item.materialName
                                  .toLowerCase()
                                  .contains(val.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: searchResults.isEmpty
                          ? const Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final item = searchResults[index];
                                return ListTile(
                                  title: Text(
                                    item.materialName,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    'Stock: ${item.currentQty} ${item.unit}',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                                  trailing: const Icon(Icons.chevron_right, size: 16),
                                  onTap: () {
                                    onSelected(item);
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
          },
        );
      },
    );
  }
}
