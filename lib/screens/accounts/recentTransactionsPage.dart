import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getCompanyInvoiceModel.dart';
import 'package:login2/models/lead_management/getRecentExpenseModel.dart';
import 'package:login2/models/lead_management/recentReceiptModel.dart';
import 'package:login2/models/clients/getInvoiceSearchData.dart' as invoice_search;
import 'package:login2/models/expense/exp_master_data.dart' as expense_master;
import 'package:login2/models/clients/customerListModel.dart' as customer_list;
import 'package:login2/service/service.dart';
import 'package:lottie/lottie.dart';

class RecentTransactionsPage extends StatefulWidget {
  final String token;
  const RecentTransactionsPage({super.key, required this.token});

  @override
  State<RecentTransactionsPage> createState() => _RecentTransactionsPageState();
}

class _RecentTransactionsPageState extends State<RecentTransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Recent Transactions',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Invoice'),
                  Tab(text: 'Receipt'),
                  Tab(text: 'Expense'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RecentInvoiceTab(token: widget.token),
          RecentReceiptTab(token: widget.token),
          RecentExpenseTab(token: widget.token),
        ],
      ),
    );
  }
}

class RecentInvoiceTab extends StatefulWidget {
  final String token;
  const RecentInvoiceTab({super.key, required this.token});

  @override
  State<RecentInvoiceTab> createState() => _RecentInvoiceTabState();
}

class _RecentInvoiceTabState extends State<RecentInvoiceTab> {
  GetCompanyInvoiceModel? invoiceModel;
  bool isLoading = true;
  String fDate = "From Date";
  String tDate = "To Date";
  String customerId = "";
  String customerName = "Choose Customer";
  String typeId = "";
  String typeName = "Choose Type";

  List<invoice_search.Customer> customers = [];
  List<invoice_search.Type> types = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchFilterData();
  }

  _fetchFilterData() async {
    final searchData = await HttpService.getInvoiceSearch(widget.token);
    if (searchData != null) {
      setState(() {
        customers = searchData.data.customers;
        types = searchData.data.types;
      });
    }
  }

  _fetchData() async {
    setState(() => isLoading = true);
    invoiceModel = await HttpService.getRecentInvoice(
      "1",
      "50",
      fDate: fDate == "From Date" ? "" : fDate,
      tDate: tDate == "To Date" ? "" : tDate,
      customerId: customerId,
      typeId: typeId,
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: isLoading
              ? Center(child: Lottie.asset('assets/main/loading.json', height: 100))
              : invoiceModel == null || (invoiceModel!.data?.lists?.isEmpty ?? true)
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: invoiceModel!.data!.lists!.length,
                      itemBuilder: (context, index) {
                        final item = invoiceModel!.data!.lists![index];
                        return _buildInvoiceItem(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showFilterDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text("Filters"),
                    const Spacer(),
                    if (fDate != "From Date" || customerId.isNotEmpty || typeId.isNotEmpty)
                      const Icon(Icons.circle, size: 8, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchData,
          ),
        ],
      ),
    );
  }

  _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: fDate,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setModalState(() => fDate = DateFormat('dd-MM-yyyy').format(date));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          label: tDate,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setModalState(() => tDate = DateFormat('dd-MM-yyyy').format(date));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: customerName,
                    onTap: () => _showCustomerPicker(setModalState),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: typeName,
                    onTap: () => _showTypePicker(setModalState),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              fDate = "From Date";
                              tDate = "To Date";
                              customerId = "";
                              customerName = "Choose Customer";
                              typeId = "";
                              typeName = "Choose Type";
                            });
                            Navigator.pop(context);
                            _fetchData();
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchData();
                          },
                          child: const Text("Apply", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSearchableSelection({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
    required Function(Map<String, String>) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(builder: (context, setStateSB) {
          List<Map<String, String>> filteredItems = items
              .where((element) => element['name']!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (val) {
                    setStateSB(() {
                      searchQuery = val;
                    });
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: filteredItems.isEmpty
                  ? const Center(child: Text("No items found"))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredItems[index]['name']!),
                          onTap: () {
                            onSelect(filteredItems[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          );
        });
      },
    );
  }

  _showCustomerPicker(StateSetter setModalState) {
    _showSearchableSelection(
      context: context,
      title: "Select Customer",
      items: customers
          .map((e) => {'id': e.id.toString(), 'name': e.name})
          .toList(),
      onSelect: (val) {
        setModalState(() {
          customerId = val['id']!;
          customerName = val['name']!;
        });
      },
    );
  }

  _showTypePicker(StateSetter setModalState) {
    _showSearchableSelection(
      context: context,
      title: "Select Type",
      items: types
          .map((e) => {'id': e.id.toString(), 'name': e.typeName})
          .toList(),
      onSelect: (val) {
        setModalState(() {
          typeId = val['id']!;
          typeName = val['name']!;
        });
      },
    );
  }

  Widget _buildDatePicker({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.customerName ?? "",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status == "Paid" ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status ?? "",
                  style: TextStyle(
                    color: item.status == "Paid" ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Invoice No: ${item.invoiceNumber}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Invoice Date: ${item.invoiceDate}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
             const SizedBox(height: 4),
           Text("Created By: ${item.createdBy}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
           Text("Created At: ${item.createdAt}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
       
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("₹ ${item.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Paid Amount", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("₹ ${item.totalPaid}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentReceiptTab extends StatefulWidget {
  final String token;
  const RecentReceiptTab({super.key, required this.token});

  @override
  State<RecentReceiptTab> createState() => _RecentReceiptTabState();
}

class _RecentReceiptTabState extends State<RecentReceiptTab> {
  RecentReceiptModel? receiptModel;
  bool isLoading = true;
  String fDate = "From Date";
  String tDate = "To Date";
  String createdById = "";
  String createdByName = "Created By";
  String headId = "";
  String headName = "Account Head";

  List<invoice_search.Staff> staffs = [];
  List<expense_master.AccountHead> heads = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchFilterData();
  }

  _fetchFilterData() async {
    final searchData = await HttpService.getInvoiceSearch(widget.token);
    if (searchData != null) {
      setState(() {
        staffs = searchData.data.staff;
      });
    }
    final masterData = await HttpService.expenseMasterData();
    if (masterData != null) {
      setState(() {
        heads = masterData.data.accountHead;
      });
    }
  }

  _fetchData() async {
    setState(() => isLoading = true);
    receiptModel = await HttpService.getRecentReceipt(
      "1",
      "50",
      fDate: fDate == "From Date" ? "" : fDate,
      tDate: tDate == "To Date" ? "" : tDate,
      createdBy: createdById,
      headId: headId,
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: isLoading
              ? Center(child: Lottie.asset('assets/main/loading.json', height: 100))
              : receiptModel == null || (receiptModel!.data?.list?.isEmpty ?? true)
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: receiptModel!.data!.list!.length,
                      itemBuilder: (context, index) {
                        final item = receiptModel!.data!.list![index];
                        return _buildReceiptItem(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showFilterDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text("Filters"),
                    const Spacer(),
                    if (fDate != "From Date" || createdById.isNotEmpty || headId.isNotEmpty)
                      const Icon(Icons.circle, size: 8, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchData,
          ),
        ],
      ),
    );
  }

  _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: fDate,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setModalState(() => fDate = DateFormat('dd-MM-yyyy').format(date));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          label: tDate,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setModalState(() => tDate = DateFormat('dd-MM-yyyy').format(date));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: createdByName,
                    onTap: () => _showStaffPicker(setModalState),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: headName,
                    onTap: () => _showHeadPicker(setModalState),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              fDate = "From Date";
                              tDate = "To Date";
                              createdById = "";
                              createdByName = "Created By";
                              headId = "";
                              headName = "Account Head";
                            });
                            Navigator.pop(context);
                            _fetchData();
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchData();
                          },
                          child: const Text("Apply", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSearchableSelection({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
    required Function(Map<String, String>) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(builder: (context, setStateSB) {
          List<Map<String, String>> filteredItems = items
              .where((element) => element['name']!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (val) {
                    setStateSB(() {
                      searchQuery = val;
                    });
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: filteredItems.isEmpty
                  ? const Center(child: Text("No items found"))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredItems[index]['name']!),
                          onTap: () {
                            onSelect(filteredItems[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          );
        });
      },
    );
  }

  _showStaffPicker(StateSetter setModalState) {
    _showSearchableSelection(
      context: context,
      title: "Select Staff",
      items: staffs
          .map((e) => {'id': e.accountId.toString(), 'name': e.accountName})
          .toList(),
      onSelect: (val) {
        setModalState(() {
          createdById = val['id']!;
          createdByName = val['name']!;
        });
      },
    );
  }

  _showHeadPicker(StateSetter setModalState) {
    _showSearchableSelection(
      context: context,
      title: "Select Account Head",
      items: heads
          .map((e) => {'id': e.accountId, 'name': e.accountName})
          .toList(),
      onSelect: (val) {
        setModalState(() {
          headId = val['id']!;
          headName = val['name']!;
        });
      },
    );
  }

  Widget _buildDatePicker({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptItem(ReceiptItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.customerName ?? "",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "₹ ${item.recieptAmount}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Receipt No: ${item.receiptNumber}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Receipt Date: ${item.receiptDate}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
            Text("Account Head: ${item.staffName}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Created By: ${item.createdName ?? ""}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
             const SizedBox(height: 4),
         Text("Created At: ${item.createdAt}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
      
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text("Invoice: ${item.invoiceNumber ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentExpenseTab extends StatefulWidget {
  final String token;
  const RecentExpenseTab({super.key, required this.token});

  @override
  State<RecentExpenseTab> createState() => _RecentExpenseTabState();
}

class _RecentExpenseTabState extends State<RecentExpenseTab> {
  GetRecentExpenseModel? expenseModel;
  bool isLoading = true;
  String fDate = "From Date";
  String tDate = "To Date";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    setState(() => isLoading = true);
    expenseModel = await HttpService.getRecentExpense(
      "1",
      "50",
      fDate: fDate == "From Date" ? "" : fDate,
      tDate: tDate == "To Date" ? "" : tDate,
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: isLoading
              ? Center(child: Lottie.asset('assets/main/loading.json', height: 100))
              : expenseModel == null || (expenseModel!.data?.list?.isEmpty ?? true)
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: expenseModel!.data!.list!.length,
                      itemBuilder: (context, index) {
                        final item = expenseModel!.data!.list![index];
                        return _buildExpenseItem(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showFilterDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(fDate == "From Date" ? "Select Dates" : "$fDate to $tDate"),
                    const Spacer(),
                    if (fDate != "From Date")
                      const Icon(Icons.circle, size: 8, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchData,
          ),
        ],
      ),
    );
  }

  _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Date Range", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: fDate,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setModalState(() => fDate = DateFormat('dd-MM-yyyy').format(date));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePicker(
                        label: tDate,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setModalState(() => tDate = DateFormat('dd-MM-yyyy').format(date));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            fDate = "From Date";
                            tDate = "To Date";
                          });
                          Navigator.pop(context);
                          _fetchData();
                        },
                        child: const Text("Clear"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          Navigator.pop(context);
                          _fetchData();
                        },
                        child: const Text("Apply", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildDatePicker({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.expCatName ?? "",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "₹ ${item.amount}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Category: ${item.expCatName}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Date: ${item.trnDate}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("From Account: ${item.fromAccount}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Account Head: ${item.toAccountPerson ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Created By: ${item.staffName}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Created At: ${item.createdAt}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          
          if (item.remarks != null && item.remarks!.isNotEmpty) ...[
            const Divider(height: 16),
            Text("Remarks: ${item.remarks}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}
