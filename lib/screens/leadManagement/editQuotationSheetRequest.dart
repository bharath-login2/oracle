import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/quick_add_customer_dialog.dart';

class EditQuotationRequestSheet extends StatefulWidget {
  final String requestId;
  final Function()? onSuccess;

  const EditQuotationRequestSheet(
      {super.key, required this.requestId, this.onSuccess});

  @override
  State<EditQuotationRequestSheet> createState() =>
      _EditQuotationRequestSheetState();
}

class _EditQuotationRequestSheetState extends State<EditQuotationRequestSheet> {
  final _formKey = GlobalKey<FormState>();

  CustomerExp? selectedCustomer;
  Staff? selectedStaff;
  String? priority;
  DateTime? dueDate;
  final TextEditingController remarksCtrl = TextEditingController();
  final TextEditingController customerCtrl = TextEditingController();
  final TextEditingController staffCtrl = TextEditingController();
  List<CustomerExp> _customers = [];
  List<Staff> _staffs = [];
  List<ProductList> _products = [];
  late Future<CustomerExpenseListModel?> customersFuture;
  List<ProductItem> products = [];
  bool isLoading = false;
  bool isInitializing = true;
  bool _isRefreshingCustomers = false;
    String? token;
  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadToken();
  }
  Future<void> _loadToken() async {
    token = await Common.getSharedPref("token");
  }

  Future<void> _initializeData() async {
    try {
      final customersData = await HttpService.getCustomers();
      final staffsData = await HttpService.getStaffs();
      final productsData = await HttpService.getProductLists("");
      final requestDetails =
          await HttpService.getRequestQuotationDetails(widget.requestId);

      if (requestDetails != null && requestDetails.status == "success") {
        final request = requestDetails.data.request;

        setState(() {
          if (customersData != null) {
            //print("Customers Data: ${customersData.toJson()}");
            _customers = customersData.data ?? [];
          }

          if (staffsData != null) {
            //print("Staffs Data: ${staffsData.toJson()}");
            _staffs = staffsData.data ?? [];
          }

          if (productsData != null) {
            print("Products Data: ${productsData.toJson()}");
            _products = productsData.data ?? [];
          }
          try {
            dueDate = DateFormat('dd-MM-yyyy').parse(request.dueDate);
          } catch (e) {
            dueDate = DateTime.now().add(const Duration(days: 7));
          }
          priority = request.priority;
          if (request.remarks != null && request.remarks!.isNotEmpty) {
            remarksCtrl.text = request.remarks!;
          }
          print("Customer ID from API: ${request.customerName}");
          print("Staff ID from API: ${request.assignedTo}");
          print("Customers count: ${_customers.length}");
          print("Staff count: ${_staffs.length}");
          if (_customers.isNotEmpty) {
            try {
              // selectedCustomer = _customers.firstWhere(
              //   (customer) => customer.id.toString() == request.customerName,
              // );
              selectedCustomer = _customers.firstWhere(
                (customer) => customer.id.toString() == request.customerName,
              );

              customerCtrl.text = selectedCustomer!.name;

              print("Selected Customer: ${selectedCustomer?.name}");
            } catch (e) {
              selectedCustomer = _customers.first;
              print(
                  "Customer not found, using first: ${selectedCustomer?.name}");
            }
          }
          if (_staffs.isNotEmpty) {
            try {
              // selectedStaff = _staffs.firstWhere(
              //   (staff) => staff.id.toString() == request.assignedTo,
              // );
              selectedStaff = _staffs.firstWhere(
                (staff) => staff.id.toString() == request.assignedTo,
              );

              staffCtrl.text = selectedStaff!.name;

              print("Selected Staff: ${selectedStaff?.name}");
            } catch (e) {
              selectedStaff = _staffs.first;
              print("Staff not found, using first: ${selectedStaff?.name}");
            }
          }
          products = request.products.map((product) {
            ProductList? matchedProduct;
            if (_products.isNotEmpty) {
              try {
                matchedProduct = _products.firstWhere(
                  (p) => p.id.toString() == product.productId,
                );
              } catch (e) {
                print("Product ${product.productId} not found in list");
                matchedProduct = ProductList(
                  id: product.productId,
                  productName: product.productName,
                  productMrp: '0',
                  sellingPrice: '0',
                  taxPercentage: '0',
                  totalAmount: '0',
                  productImage: '',
                  categoryName: '',
                  subCategory: '',
                  contentId: '',
                );
              }
            }

            return ProductItem(
              product: matchedProduct,
              qty: product.quantity,
            )..productCtrl.text = matchedProduct?.productName ?? '';
          }).toList();

          print("Products loaded: ${products.length}");
          isInitializing = false;
        });
      } else {
        setState(() => isInitializing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load request details'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error in _initializeData: $e");
      setState(() => isInitializing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                  "Edit Quotation Request",
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
            child: isInitializing
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                          Row(
                            children: [
                              Expanded(
                                child: _cancelButton(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _submitButton(),
                              ),
                            ],
                          ),
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

  // Widget _customerDropdown() {
  //   return DropdownButtonFormField<CustomerExp>(
  //     decoration: _inputDecoration(Icons.person, "Select Customer"),
  //     value: selectedCustomer,
  //     items: _customers
  //         .map(
  //           (e) => DropdownMenuItem(
  //             value: e,
  //             child: Text(e.name),
  //           ),
  //         )
  //         .toList(),
  //     onChanged: (v) => setState(() => selectedCustomer = v),
  //     validator: (v) => v == null ? "Required" : null,
  //     isExpanded: true,
  //   );
  // }
  Widget _customerDropdown() {
    return TextFormField(
      controller: customerCtrl,
      readOnly: true,
      validator: (_) => selectedCustomer == null ? "Required" : null,
      onTap: () {
        _showCustomerSearchDialog(_customers);
      },
      decoration: _inputDecoration(Icons.person, "Select Customer").copyWith(
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
    );
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
                              .where((c) => c.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
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
                      ),
                    ),
                    const SizedBox(height: 10),
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

  // Widget _staffDropdown() {
  //   return DropdownButtonFormField<Staff>(
  //     decoration: _inputDecoration(Icons.group, "Select Staff"),
  //     value: selectedStaff,
  //     items: _staffs
  //         .map(
  //           (e) => DropdownMenuItem(
  //             value: e,
  //             child: Text(e.name),
  //           ),
  //         )
  //         .toList(),
  //     onChanged: (v) => setState(() => selectedStaff = v),
  //     validator: (v) => v == null ? "Required" : null,
  //     isExpanded: true,
  //   );
  // }

  Widget _staffDropdown() {
    return TextFormField(
      controller: staffCtrl,
      readOnly: true,
      validator: (_) => selectedStaff == null ? "Required" : null,
      onTap: () {
        _showStaffSearchDialog(_staffs);
      },
      decoration: _inputDecoration(Icons.group, "Select Staff").copyWith(
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
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
                    // 🔍 Search
                    TextField(
                      controller: searchCtrl,
                        focusNode: searchFocusNode,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = staffs
                              .where((s) => s.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
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
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 📋 List
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
      isExpanded: true,
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
      isDense: true,
    );
  }

  Widget _buildProductsSection() {
    return Column(
      children: [
        ...List.generate(products.length, (index) {
          final item = products[index];
          return _buildProductItem(item, index);
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
  }

  Widget _buildProductItem(ProductItem item, int index) {
    final availableProducts = _products.where((p) {
      if (item.product?.id == p.id) return true;
      final isAlreadySelected = products
          .where((product) => product.product != null)
          .any((product) => product.product!.id == p.id && product != item);
      return !isAlreadySelected;
    }).toList();

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
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => products.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // DropdownButtonFormField<ProductList>(
            //   decoration: const InputDecoration(
            //     labelText: "Select Product",
            //     border: OutlineInputBorder(),
            //     isDense: true,
            //   ),
            //   value: item.product,
            //   items: availableProducts
            //       .map(
            //         (p) => DropdownMenuItem(
            //           value: p,
            //           child: Text(p.productName),
            //         ),
            //       )
            //       .toList(),
            //   onChanged: (v) => setState(() => item.product = v),
            //   validator: (v) => v == null ? "Required" : null,
            //   isExpanded: true,
            // ),
            TextFormField(
              controller: item.productCtrl,
              readOnly: true,
              validator: (_) => item.product == null ? "Required" : null,
              onTap: () {
                _showProductSearchDialog(item);
              },
              decoration: const InputDecoration(
                labelText: "Select Product",
                border: OutlineInputBorder(),
                isDense: true,
                suffixIcon: Icon(Icons.arrow_drop_down),
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

  void _showProductSearchDialog(ProductItem item) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController searchCtrl = TextEditingController();

        List<ProductList> filteredList = _products.where((p) {
          if (item.product?.id == p.id) return true;

          return !products.any(
            (e) => e.product != null && e.product!.id == p.id,
          );
        }).toList();

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
                    TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredList = _products.where((p) {
                            final matchesSearch = p.productName
                                .toLowerCase()
                                .contains(value.toLowerCase());

                            final notSelected = !products.any(
                              (e) =>
                                  e.product != null &&
                                  e.product!.id == p.id &&
                                  e != item,
                            );

                            return matchesSearch && notSelected;
                          }).toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search product",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                      item.productCtrl.text =
                                          product.productName;
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
      height: 48,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 33, 91, 129),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                "Update",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: const Text(
          "Cancel",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select customer"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select staff"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select priority"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select due date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
        'token': await Common.getSharedPref('token') ?? '',
        'id': widget.requestId,
        'customer_name': selectedCustomer!.id.toString(),
        'assigned_to': selectedStaff!.userIdStaff.toString(),
        'priority': priority,
        'due_date': DateFormat('dd-MM-yyyy').format(dueDate!),
        'remarks': remarksCtrl.text,
        'products': productsJson,
      });

      final result = await HttpService.updateQuotationRequest(formData);

      if (result != null && result['status'] == "success") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Request updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? "Failed to update request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("🔥 Error in updateQuotationRequest: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server error: $e"),
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
  final TextEditingController productCtrl = TextEditingController();

  ProductItem({this.product, this.qty = 1});
}
