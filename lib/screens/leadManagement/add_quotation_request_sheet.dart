import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart'; // Add this import
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/service/service.dart';
// Add this import if you have QuickAddCustomerDialog widget
import 'package:login2/widgets/quick_add_customer_dialog.dart';

class AddQuotationRequestSheet extends StatefulWidget {
  final Function()? onSuccess;

  const AddQuotationRequestSheet({super.key, this.onSuccess});

  @override
  State<AddQuotationRequestSheet> createState() =>
      _AddQuotationRequestSheetState();
}

class _AddQuotationRequestSheetState extends State<AddQuotationRequestSheet> {
  final _formKey = GlobalKey<FormState>();

  CustomerExp? selectedCustomer;
  Staff? selectedStaff;
  String? priority = "Normal";
  DateTime? dueDate;
  final TextEditingController remarksCtrl = TextEditingController();
  final TextEditingController customerCtrl = TextEditingController();
  final TextEditingController staffCtrl = TextEditingController();

  late Future<CustomerExpenseListModel?> customersFuture;
  late Future<StaffListModel?> staffsFuture;
  late Future<ProductListModel?> productsFuture;

  List<ProductItem> products = [ProductItem()];
  bool isLoading = false;
  bool _isRefreshingCustomers = false;
  String? token;

  @override
  void initState() {
    super.initState();
    customersFuture = HttpService.getCustomers();
    staffsFuture = HttpService.getStaffs();
    productsFuture = HttpService.getProductLists("");
    _loadToken();
  }

  Future<void> _loadToken() async {
    token = await Common.getSharedPref("token");
  }

  @override
  void dispose() {
    customerCtrl.dispose();
    remarksCtrl.dispose();
    staffCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "New Quotation Request",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Customer"),
                    _customerDropdown(),
                    const SizedBox(height: 16),
                    _buildLabel("Assign To"),
                    _staffDropdown(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Due Date"),
                              _dueDatePicker(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Priority"),
                              _priorityDropdown(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Products"),
                    const SizedBox(height: 8),
                    _buildProductsSection(),
                    const SizedBox(height: 20),
                    _buildLabel("Remarks"),
                    _remarksField(),
                    const SizedBox(height: 24),
                    _submitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _customerDropdown() {
    return FutureBuilder<CustomerExpenseListModel?>(
      future: customersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "No customers found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final customers = snapshot.data!.data;

        return TextFormField(
          controller: customerCtrl,
          readOnly: true,
          validator: (_) => selectedCustomer == null ? "Required" : null,
          onTap: () {
            _showCustomerSearchDialog(customers);
          },
          decoration: InputDecoration(
            labelText: "Select Customer",
            prefixIcon: const Icon(Icons.person, color: Colors.grey),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  void _showCustomerSearchDialog(List<CustomerExp> customers) {
    FocusNode searchFocusNode = FocusNode();
    bool shouldAutoFocus = true;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<CustomerExp> filteredList = List.from(customers);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (shouldAutoFocus) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  FocusScope.of(context).requestFocus(searchFocusNode);
                }
              });
            }
            return AlertDialog(
              scrollable: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Customer"),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue, size: 24),
                    onPressed: () async {
                      shouldAutoFocus = false;
                      final result = await _showQuickAddCustomerDialog(context);
                      if (result != null && result) {
                        Navigator.pop(context);
                        await _refreshAfterCustomerAdded();
                      } else {
                        shouldAutoFocus = true;
                        if (mounted) {
                          _showCustomerSearchDialog(customers);
                        }
                      }
                      // final result = await _showQuickAddCustomerDialog(context);
                      // if (result != null && result) {
                      //   await _refreshAfterCustomerAdded();
                      //   // Re-open the dialog with updated list
                      //   if (mounted) {
                      //     Navigator.pop(context);
                      //     _showCustomerSearchDialog(customers);
                      //   }
                      // }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      focusNode: searchFocusNode,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = customers
                              .where(
                                (c) => c.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search customer",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 📋 CUSTOMER LIST
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No customers found"))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final customer = filteredList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedCustomer = customer;
                                      customerCtrl.text = customer.name;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      customer.name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
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

  Future<void> _refreshAfterCustomerAdded() async {
    setState(() {
      _isRefreshingCustomers = true;
    });

    try {
      // Refresh customer list
      customersFuture = HttpService.getCustomers();
      setState(() {});

      if (mounted) {
        Common.toastMessaage('Customer added successfully', Colors.green);
      }
    } catch (e) {
      log("Error refreshing customers: $e");
      if (mounted) {
        Common.toastMessaage('Failed to refresh customers', Colors.red);
      }
    } finally {
      setState(() {
        _isRefreshingCustomers = false;
      });
    }
  }

  Future<bool?> _showQuickAddCustomerDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: QuickAddCustomerDialog(
            token: token ?? '',
            onCustomerAdded: (success) async {
              if (success) {
                Navigator.pop(context, true);
              }
            },
          ),
        );
      },
    );
  }

  Widget _staffDropdown() {
    return FutureBuilder<StaffListModel?>(
      future: staffsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "No staff found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final staffs = snapshot.data!.data;

        return TextFormField(
          controller: staffCtrl,
          readOnly: true,
          validator: (_) => selectedStaff == null ? "Required" : null,
          onTap: () {
            _showStaffSearchDialog(staffs);
          },
          decoration: InputDecoration(
            labelText: "Select Staff",
            prefixIcon: const Icon(Icons.group, color: Colors.grey),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  void _showStaffSearchDialog(List<Staff> staffs) {
    FocusNode searchFocusNode = FocusNode();
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<Staff> filteredList = List.from(staffs);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusScope.of(context).requestFocus(searchFocusNode);
            });
            return AlertDialog(
              scrollable: true,
              title: const Text("Select Staff"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      focusNode: searchFocusNode,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = staffs
                              .where(
                                (s) => s.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search staff",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No staff found"))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final staff = filteredList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedStaff = staff;
                                      staffCtrl.text = staff.name;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      staff.name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
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

  Widget _dueDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          initialDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
        );
        if (picked != null) setState(() => dueDate = picked);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dueDate == null
                    ? "Select Date"
                    : DateFormat('dd MMM yyyy').format(dueDate!),
                style: TextStyle(
                  color: dueDate == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(Icons.flag, "Select Priority"),
      value: priority,
      items: const [
        DropdownMenuItem(value: "High", child: Text("High")),
        DropdownMenuItem(value: "Normal", child: Text("Normal")),
        DropdownMenuItem(value: "Critical", child: Text("Critical")),
      ],
      onChanged: (v) => setState(() => priority = v),
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _remarksField() {
    return TextFormField(
      controller: remarksCtrl,
      maxLines: 3,
      decoration: _inputDecoration(Icons.note, "Optional remarks..."),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildProductsSection() {
    return FutureBuilder<ProductListModel?>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return Center(
            child: Text(
              "No products available",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            ...List.generate(products.length, (index) {
              final item = products[index];
              return _buildProductItem(item, index, snapshot.data!);
            }),
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: () => setState(() => products.add(ProductItem())),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Product"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductItem(
      ProductItem item, int index, ProductListModel productList) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Product ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (products.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => products.removeAt(index)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.ctrl,
              readOnly: true,
              validator: (_) => item.product == null ? "Required" : null,
              onTap: () {
                _showProductSearchDialog(item, productList.data);
              },
              decoration: const InputDecoration(
                labelText: "Select Product",
                prefixIcon: Icon(Icons.inventory_2, color: Colors.grey),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quantity:",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (item.qty > 1) setState(() => item.qty--);
                      },
                    ),
                    Container(
                      width: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          item.qty.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => item.qty++),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSearchDialog(ProductItem item, List<ProductList> products) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();
        List<ProductList> filteredList = List.from(products);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text("Select Product"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    // 🔍 SEARCH BOX
                    TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = products
                              .where(
                                (p) => p.productName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search product",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 📦 PRODUCT LIST
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No products found"))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final product = filteredList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.product = product;
                                      item.ctrl.text = product.productName;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      product.productName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
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

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 33, 91, 129),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Submit Request",
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (products.isEmpty || products.any((p) => p.product == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select all products"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final productsJson = jsonEncode(
        products
            .map((p) => {
                  "product_id": p.product!.id.toString(),
                  "quantity": p.qty.toString(),
                })
            .toList(),
      );

      final formData = FormData.fromMap({
        'customer_name': selectedCustomer!.id.toString(),
        'assigned_to': selectedStaff!.userIdStaff.toString(),
        'priority': priority,
        'due_date': DateFormat('dd-MM-yyyy').format(dueDate!),
        'remarks': remarksCtrl.text,
        'products': productsJson,
      });

      final result = await HttpService().createQuotationRequest(formData);

      if (result != null && result['status'] == "success") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? "Failed to create request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      log("🔥 Error in createQuotationRequest: $e");
      log("StackTrace: $st");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error, please try again"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}

class ProductItem {
  ProductList? product;
  int qty;
  TextEditingController ctrl = TextEditingController();

  ProductItem({this.product, this.qty = 1});
}
