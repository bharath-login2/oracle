import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:login2/screens/accounts/clients/addClients.dart';
import 'package:login2/screens/product_mannagement/add_products.dart';
import 'package:login2/widgets/accountHeadDialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/clients/customerListModel.dart';
import '../../../models/clients/ivoiceAddCommonDetailsModel.dart';
import '../../../service/service.dart';

class AddInvoiceUpdated extends StatefulWidget {
  final String token;
  final String clientId;
  final String proformaId;

  const AddInvoiceUpdated(this.token, this.clientId, this.proformaId,
      {super.key});

  @override
  State<AddInvoiceUpdated> createState() => _AddInvoiceUpdatedState();
}

class _AddInvoiceUpdatedState extends State<AddInvoiceUpdated> {
  InvoiceAddCommonDetailsModel? invDetails;
  bool loading = true;
  bool saving = false;
  List<Staff> filteredStaff = [];
  String? selectedCustomer;
  String? selectedCustomerName;
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  List<Product> products = [];
  // List<Product> searchResults = [];
  List<ProductList> allProducts = [];
  List<ProductList> filteredProducts = [];
  List<ProductList> searchResults = [];
  List<ListElement> allHeads = [];
  List<ListElement> filteredHeads = [];
  String staffId = "";
  final Map<String, Map<String, dynamic>> addedProducts = {};
  double subtotal = 0, tax = 0;
  String? paymentStatus;
  String? paymentMethod;
  String? collectedBy;
  String? paidDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Color paidColor = Colors.black;
  TextEditingController paidAmount = TextEditingController();
  String staffName = "Select Account Head";
  List<String> targetGroupNames = [];
  bool customerLoading = false;
  String? activeProductKey;
  double total = 0;
  TextEditingController customerSearchController = TextEditingController();
  TextEditingController productSearchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadCustomerList();
    _getProductList();
    _getAccountHeads();
  }

  Future<void> _loadCustomerList() async {
    try {
      final customerList = await HttpService.customerList(widget.token);
      setState(() {
        customers = customerList.data ?? [];
        filteredCustomers = List.from(customers);
        loading = false;
      });
      print('Loaded ${customers.length} customers');
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customers: $e')));
    }
  }

  void _clearProductSearch() {
    productSearchController.clear();
    setState(() {
      searchResults.clear();
    });
  }

  Future<void> _getProductList() async {
    try {
      setState(() => loading = true);
      final productList = await HttpService.getProductLists(widget.token);
      setState(() {
        allProducts = productList.data ?? [];
        filteredProducts = List.from(allProducts);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  Future<void> _getAccountHeads() async {
    try {
      final headList = await HttpService.getAccountHead();
      if (headList != null && headList.status == true) {
        setState(() {
          allHeads = headList.data.lists;
          filteredHeads = List.from(allHeads);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(headList?.message ?? 'Failed to load account heads')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load account heads: $e')),
      );
    }
  }

  Future<void> _loadInvoiceDetails(String customerId) async {
    setState(() => customerLoading = true);
    try {
      final commonDetails =
          await HttpService.invoiceCommonDetails(widget.token, customerId);

      setState(() {
        invDetails = commonDetails;
        products = commonDetails.data?.products ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load invoice details: $e')),
      );
    } finally {
      setState(() => customerLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults.clear();
      } else {
        searchResults = allProducts
            .where((p) =>
                p.productName.toLowerCase().contains(query.toLowerCase()) ||
                p.totalAmount.contains(query))
            .toList();
      }
    });
  }

  void _addProduct(ProductList product, {int increment = 1}) {
    final key = product.id;
    setState(() {
      activeProductKey = key;
      if (addedProducts.containsKey(key)) {
        addedProducts[key]!['qty'] =
            (addedProducts[key]!['qty'] as int) + increment;
      } else {
        addedProducts[key] = {'product': product, 'qty': 1};
      }
      _calculateTotals();
      _showProductUpdateMessage();
    });
  }

  void _decreaseProduct(ProductList product, {int decrement = 1}) {
    final key = product.id;
    if (!addedProducts.containsKey(key)) return;

    setState(() {
      activeProductKey = key;
      final current = addedProducts[key]!['qty'] as int;
      final updated = current - decrement;
      if (updated > 0) {
        addedProducts[key]!['qty'] = updated;
      } else {
        addedProducts.remove(key);
      }
      _calculateTotals();
      _showProductUpdateMessage();
    });
  }

  void _removeProduct(ProductList product) {
    final key = product.id;
    setState(() {
      addedProducts.remove(key);
      _calculateTotals();
      _showProductUpdateMessage();
    });
  }

  void _updateProductQuantity(ProductList product, int newQuantity) {
    final key = product.id;
    if (newQuantity <= 0) {
      _removeProduct(product);
      return;
    }

    setState(() {
      if (addedProducts.containsKey(key)) {
        addedProducts[key]!['qty'] = newQuantity;
      } else {
        addedProducts[key] = {'product': product, 'qty': newQuantity};
      }
      _calculateTotals();
      _showProductUpdateMessage();
    });
  }

  void _calculateTotals() {
    total = 0;
    for (final entry in addedProducts.entries) {
      final prod = entry.value['product'] as ProductList;
      final qty = entry.value['qty'] as int;
      final price = double.tryParse(prod.totalAmount) ?? 0;
      total += price * qty;
    }

    if (paymentStatus == "Paid") {
      paidAmount.text = total.toStringAsFixed(2);
    }
    setState(() {});
  }

  void _showProductUpdateMessage() {
    final itemCount = addedProducts.length;
    final totalItems = addedProducts.values
        .fold<int>(0, (sum, item) => sum + (item['qty'] as int));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Order updated: $totalItems items in cart",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
      ),
    );
  }

  Future<void> _saveInvoice({bool download = false}) async {
  if (selectedCustomer == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a customer')),
    );
    return;
  }

  if (addedProducts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please add at least one product')),
    );
    return;
  }

  if (paymentStatus == "Partial" || paymentStatus == "Paid") {
    if (staffId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account head')),
      );
      return;
    }
  }

  setState(() => saving = true);
  try {
    final invoiceItems = addedProducts.entries.map((entry) {
      final ProductList p = entry.value['product'] as ProductList;
      final int qty = entry.value['qty'] as int;
      return {
        'product_id': p.id,
        'qty': qty,
        'rate': p.totalAmount,
        'total': (double.tryParse(p.totalAmount) ?? 0) * qty,
      };
    }).toList();

    String paymentMethodValue;
    if ((paymentMethod ?? '').toLowerCase() == 'cash') {
      paymentMethodValue = '1';
    } else if ((paymentMethod ?? '').toLowerCase() == 'Bank Transfer') {
      paymentMethodValue = '5';
    } else {
      paymentMethodValue = '0';
    }

    final payload = {
      'client_id': widget.clientId,
      'customer_id': selectedCustomer,
      'products': invoiceItems,
      'total': total.toStringAsFixed(2),
      'payment_status': paymentStatus ?? 'Paid',
      'payment_method': paymentMethodValue,
      'paid_amount':
          paidAmount.text.trim().isEmpty ? '0' : paidAmount.text.trim(),
      'paid_date': paidDate,
      'collected_by': staffId,
      'account_head_name': staffName,
      'is_download': download ? '1' : '0', 
      'token': widget.token,
    };

    final response = await HttpService.addInvoiceUpdated(payload);
    
    if (response.status == true) {
   
      if (download && response.data is String && (response.data as String).contains('http')) {
        final pdfUrl = response.data as String;
        await _handlePdfDownload(pdfUrl);
      } else {
        // Regular save success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Invoice saved successfully',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        addedProducts.clear();
        total = 0;
        paidAmount.clear();
        _clearProductSearch();
        searchResults.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Failed to save invoice'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => saving = false);
  }
}


  Future<void> _handlePdfDownload(String pdfUrl) async {
  try {
    final action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invoice Generated'),
          content: const Text('What would you like to do with the invoice?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'view'),
              child: const Text('View PDF'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'download'),
              child: const Text('Download PDF'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (action == 'view') {
      await _viewPdf(pdfUrl);
    } else if (action == 'download') {
      await _downloadPdf(pdfUrl);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error handling PDF: $e')),
    );
  }
}

Future<void> _viewPdf(String url) async {
  final Uri pdfUri = Uri.parse(url);
  
  if (await canLaunchUrl(pdfUri)) {
    await launchUrl(
      pdfUri,
      mode: LaunchMode.externalApplication, 
    );
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> _downloadPdf(String url) async {
  try {
  
    final Directory? downloadsDir = await getExternalStorageDirectory();
    final String savePath = '${downloadsDir?.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';

   
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadsDir?.path ?? '',
      fileName: 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
      showNotification: true,
      openFileFromNotification: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download started'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download failed: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sales',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Customer ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (customerLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showCustomerDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              selectedCustomerName ?? 'Select Customer',
                              style: TextStyle(
                                color: selectedCustomerName != null
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down,
                              color: Colors.grey, size: 20),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.blue, size: 22),
                            tooltip: 'Add New Customer',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddClients(widget.token, createOrder: false)),
                              );

                              if (result == true) {
                                await _loadCustomerList();
                                if (customers.isNotEmpty) {
                                  final latestCustomer = customers.first;
                                  setState(() {
                                    selectedCustomer =
                                        latestCustomer.id.toString();
                                    selectedCustomerName = latestCustomer.name;
                                  });
                                  _loadInvoiceDetails(
                                      latestCustomer.id.toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Customer "${latestCustomer.name}" added and selected'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: productSearchController,
                        onChanged: (value) {
                          setState(() {
                            _onSearchChanged(value);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search product name',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: productSearchController.text.isEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.blue, size: 22),
                                  tooltip: 'Add New Product',
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddProducts()),
                                    );

                                    if (result == true || result != null) {
                                      await _getProductList();
                                      setState(() {
                                        _clearProductSearch();
                                      });
                                    }
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _clearProductSearch();
                                    setState(() {});
                                  },
                                  splashRadius: 20,
                                ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (searchResults.isNotEmpty)
                    Column(
                      children: searchResults.map((p) {
                        final key = p.id;
                        final int qty = addedProducts.containsKey(key)
                            ? (addedProducts[key]!['qty'] as int)
                            : 0;

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade100,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: p.productImage.isNotEmpty
                                      ? Image.network(
                                          p.productImage,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/icons/comingsoon.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/icons/comingsoon.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _iconButton(
                                              icon: Icons.remove,
                                              onTap: () => _decreaseProduct(p)),
                                          Container(
                                            width: 50,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: TextFormField(
                                              controller: TextEditingController(
                                                  text: '$qty'),
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(4),
                                                border: OutlineInputBorder(),
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              onChanged: (value) {
                                                if (value.isNotEmpty) {
                                                  int newQty =
                                                      int.tryParse(value) ?? 1;
                                                  _updateProductQuantity(
                                                      p, newQty);
                                                }
                                              },
                                            ),
                                          ),
                                          _iconButton(
                                              icon: Icons.add,
                                              onTap: () => _addProduct(p)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${p.totalAmount}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => _addProduct(p),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('+ Add',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Start typing to search products...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (addedProducts.isNotEmpty) _orderSummarySection(),
                  const SizedBox(height: 25),
                  _buildPaymentSection(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _saveButton("Save & Download", download: true),
                      const SizedBox(width: 12),
                      _saveButton("Save", download: false),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _saveButton(String title, {bool download = false}) => ElevatedButton(
        onPressed: saving ? null : () => _saveInvoice(download: download),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: saving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
      );

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.black54, size: 18),
      ),
    );
  }

  Widget _orderSummarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...addedProducts.entries.map((entry) {
            final ProductList p = entry.value['product'] as ProductList;
            final int qty = entry.value['qty'] as int;
            final double price = double.tryParse(p.totalAmount) ?? 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FFF2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: p.productImage.isNotEmpty
                        ? Image.network(
                            p.productImage,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/icons/comingsoon.jpg',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/icons/comingsoon.jpg',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(p.productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                            Text('₹${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B48FF))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: const Color(0xFF6B48FF),
                              onPressed: () => _decreaseProduct(p),
                            ),
                            Container(
                              width: 50,
                              child: TextFormField(
                                controller: TextEditingController(text: '$qty'),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(4),
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    int newQty = int.tryParse(value) ?? 1;
                                    _updateProductQuantity(p, newQty);
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: const Color(0xFF6B48FF),
                              onPressed: () => _addProduct(p),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeProduct(p),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          // Only show total, remove subtotal and tax
          _rowTotal('Total', total, bold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final paymentStatusList = ['Paid', 'Partial', 'Unpaid'];
    final paymentMethods = ['Cash', 'Bank Transfer'];
    paymentStatus ??= 'Paid';
    paymentMethod ??= 'Cash';

    if (paidAmount.text.isEmpty && total > 0 && paymentStatus == "Paid") {
      paidAmount.text = total.toStringAsFixed(2);
    }

    void updatePaidAmount(String val) {
      if (val.isEmpty) {
        // If field is cleared, set to 0 and reset color
        paidColor = Colors.black;
        setState(() {});
        return;
      }

      double entered = double.tryParse(val) ?? 0;

      if (paymentStatus == "Partial") {
        if (entered >= total) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Partial amount cannot be equal to or more than Total"),
              backgroundColor: Colors.redAccent,
            ),
          );

          // Set to total - 1
          double partialAmount = total > 1 ? total - 1 : 0;
          paidAmount.text = partialAmount.toStringAsFixed(2);
          paidAmount.selection = TextSelection.fromPosition(
            TextPosition(offset: paidAmount.text.length),
          );
          paidColor = Colors.red;
        } else if (entered < 0) {
          // Handle negative amounts
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Amount cannot be negative"),
              backgroundColor: Colors.redAccent,
            ),
          );
          paidAmount.text = "0";
          paidAmount.selection = TextSelection.fromPosition(
            TextPosition(offset: paidAmount.text.length),
          );
          paidColor = Colors.red;
        } else {
          paidColor = Colors.black;
        }
      } else if (paymentStatus == "Paid") {
        if (entered > total) {
          paidColor = Colors.red;
        } else {
          paidColor = Colors.black;
        }
      } else {
        // For Unpaid status
        paidColor = Colors.black;
      }
      setState(() {});
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildFormRow(
                  "Pay Status * :",
                  _dropdown(paymentStatusList, paymentStatus, "Select Status",
                      (newVal) {
                    setState(() {
                      paymentStatus = newVal ?? 'Paid';
                      if (paymentStatus == 'Paid') {
                        paidAmount.text = total.toStringAsFixed(2);
                        paidColor = Colors.black;
                      } else if (paymentStatus == 'Unpaid') {
                        paidAmount.clear();
                        paidColor = Colors.black;
                      } else if (paymentStatus == 'Partial') {
                        // Set to total - 1 when switching to Partial
                        double partialAmount = total > 1 ? total - 1 : 0;
                        paidAmount.text = partialAmount.toStringAsFixed(2);
                        paidColor = Colors.black;
                      }
                    });
                  }),
                ),
              ),
              const SizedBox(width: 12),
              if (paymentStatus != "Unpaid")
                Expanded(
                  child: _buildFormRow(
                    "Paid Amount * :",
                    TextFormField(
                      controller: paidAmount,
                      readOnly: paymentStatus == "Paid",
                      style: TextStyle(
                          color: paidColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration().copyWith(
                        hintText: paymentStatus == "Partial"
                            ? "${(total > 1 ? total - 1 : 0).toStringAsFixed(2)}"
                            : "${total.toStringAsFixed(2)}",
                        prefixText: "₹ ",
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      onChanged: updatePaidAmount,
                      onTap: () {
                        if (paymentStatus == "Partial" &&
                            paidAmount.text ==
                                (total > 1 ? total - 1 : 0)
                                    .toStringAsFixed(2)) {
                          paidAmount.clear();
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormRow(
                  "Paid Date :",
                  DateTimePicker(
                    type: DateTimePickerType.date,
                    dateMask: 'dd-MM-yyyy',
                    initialValue: paidDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    decoration: _inputDecoration(),
                    onChanged: (val) => setState(() => paidDate = val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (paymentStatus == "Paid" || paymentStatus == "Partial")
                Expanded(
                  child: _buildFormRow(
                    "Payment Method * :",
                    _dropdown(
                        paymentMethods,
                        paymentMethod,
                        "Select Method",
                        (newVal) =>
                            setState(() => paymentMethod = newVal ?? 'Cash')),
                  ),
                ),
            ],
          ),
          if (paymentStatus == "Paid" || paymentStatus == "Partial") ...[
            const SizedBox(height: 12),
            _buildFormRow("Account Head * :", _accountHeadSelector()),
          ],
        ],
      ),
    );
  }

  Widget _dropdown(List<String> items, String? value, String hint,
      Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(hint),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(e)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFormRow(String title, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          child,
        ],
      );

  InputDecoration _inputDecoration() => InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
      );

  // Widget _accountHeadSelector() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: GestureDetector(
  //           onTap: () => _showAccountHeadDialog(context),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.grey.shade300,
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     staffName,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       color: staffName != "Select Account Head"
  //                           ? Colors.black
  //                           : Colors.grey,
  //                     ),
  //                   ),
  //                 ),
  //                 Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       InkWell(
  //         onTap: () {
  //           showDialog(
  //             context: context,
  //             builder: (context) => const AddAccountHeadDialog(),
  //           ).then((_) {
  //             _getAccountHeads();
  //           });
  //         },
  //         borderRadius: BorderRadius.circular(30),
  //         child: Container(
  //           decoration: const BoxDecoration(
  //             color: Colors.blue,
  //             shape: BoxShape.circle,
  //           ),
  //           padding: const EdgeInsets.all(8),
  //           child: const Icon(
  //             Icons.add,
  //             color: Colors.white,
  //             size: 20,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _accountHeadSelector() {
    return GestureDetector(
      onTap: () => _showAccountHeadDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                staffName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: staffName != "Select Account Head"
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.blue, size: 22),
                  tooltip: 'Add New Account Head',
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const AddAccountHeadDialog(),
                    );
                    if (result == true || result != null) {
                      await _getAccountHeads();
                    }
                  },
                ),
              ],
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            //     const SizedBox(width: 8),
            //     InkWell(
            //       onTap: () {
            //         showDialog(
            //           context: context,
            //           builder: (context) => const AddAccountHeadDialog(),
            //         ).then((_) {
            //           _getAccountHeads();
            //         });
            //       },
            //       borderRadius: BorderRadius.circular(20),
            //       child: Container(
            //         decoration: const BoxDecoration(
            //           color: Color.fromARGB(255, 255, 255, 255),
            //           shape: BoxShape.circle,
            //         ),
            //         padding: const EdgeInsets.all(6),
            //         child: const Icon(
            //           Icons.add,
            //           color: Colors.blue,
            //           size: 16,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showCustomerDialog(BuildContext context) {
    _loadCustomerList().then((_) {
      setState(() {
        customerSearchController.clear();
        filteredCustomers = List.from(customers);
      });
    });

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.only(
                  left: 20, right: 10, top: 16, bottom: 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Customer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddClients(widget.token),
                        ),
                      );

                      if (result == true) {
                        await _loadCustomerList();
                        if (customers.isNotEmpty) {
                          final latestCustomer = customers.first;
                          setState(() {
                            selectedCustomer = latestCustomer.id.toString();
                            selectedCustomerName = latestCustomer.name;
                          });
                          _loadInvoiceDetails(latestCustomer.id.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Customer "${latestCustomer.name}" added and selected'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.blue),
                    label: const Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )

                  // IconButton(
                  //   icon: const Icon(Icons.add_circle_outline,
                  //       color: Colors.blue, size: 24),
                  //   tooltip: 'Add New Customer',
                  //   onPressed: () async {
                  //     Navigator.pop(context);
                  //     final result = await Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => AddClients(widget.token)),
                  //     );

                  //     if (result == true) {
                  //       await _loadCustomerList();
                  //       if (customers.isNotEmpty) {
                  //         final latestCustomer = customers.first;
                  //         this.setState(() {
                  //           selectedCustomer = latestCustomer.id.toString();
                  //           selectedCustomerName = latestCustomer.name;
                  //         });
                  //         _loadInvoiceDetails(latestCustomer.id.toString());
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //             content: Text(
                  //                 'Customer "${latestCustomer.name}" added and selected'),
                  //             backgroundColor: Colors.green,
                  //             duration: const Duration(seconds: 3),
                  //           ),
                  //         );
                  //       }
                  //     }
                  //   },
                  // )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: customerSearchController,
                        autocorrect: false,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search customer name...',
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredCustomers = customers
                                .where((item) => (item.name ?? '')
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: filteredCustomers.isEmpty
                          ? Text(
                              "No matching customers found",
                              style: TextStyle(color: Colors.grey),
                            )
                          : ListView.builder(
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                final isSelected =
                                    selectedCustomer == customer.id.toString();
                                return ListTile(
                                  title:
                                      Text(customer.name ?? 'Unknown Customer'),
                                  trailing: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : null,
                                  tileColor: isSelected
                                      ? Colors.green.withOpacity(0.1)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    this.setState(() {
                                      selectedCustomer = customer.id.toString();
                                      selectedCustomerName = customer.name;
                                    });
                                    _loadInvoiceDetails(customer.id.toString());
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Future<dynamic> _showCustomerDialog(BuildContext context) {
  //   _loadCustomerList().then((_) {
  //     setState(() {
  //       customerSearchController.clear();
  //       filteredCustomers = List.from(customers);
  //     });
  //   });

  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             titlePadding: const EdgeInsets.only(
  //                 left: 20, right: 10, top: 16, bottom: 0),
  //             title: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const Text(
  //                   "Select Customer",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //                 ),
  //                 // In _showCustomerDialog method - update the IconButton
  //                 IconButton(
  //                   icon: const Icon(Icons.add_circle_outline,
  //                       color: Colors.blue, size: 24),
  //                   tooltip: 'Add New Customer',
  //                   onPressed: () async {
  //                     Navigator.pop(context); // Close customer dialog first

  //                     final result = await Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) => AddClients(widget.token)),
  //                     );

  //                     if (result == true) {
  //                       await _loadCustomerList();
  //                       if (customers.isNotEmpty) {
  //                         final latestCustomer = customers.first;
  //                         setState(() {
  //                           selectedCustomer = latestCustomer.id.toString();
  //                           selectedCustomerName = latestCustomer.name;
  //                         });
  //                         _loadInvoiceDetails(latestCustomer.id.toString());
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(
  //                             content: Text(
  //                                 'Customer "${latestCustomer.name}" added and selected'),
  //                             backgroundColor: Colors.green,
  //                             duration: const Duration(seconds: 3),
  //                           ),
  //                         );
  //                       }
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: TextField(
  //                       controller: customerSearchController,
  //                       autocorrect: false,
  //                       autofocus: true,
  //                       decoration: const InputDecoration(
  //                         hintText: 'Search customer name...',
  //                         prefixIcon: Icon(Icons.search),
  //                         contentPadding: EdgeInsets.all(8),
  //                         border: OutlineInputBorder(),
  //                       ),
  //                       onChanged: (value) {
  //                         setState(() {
  //                           filteredCustomers = customers
  //                               .where((item) => (item.name ?? '')
  //                                   .toLowerCase()
  //                                   .contains(value.toLowerCase()))
  //                               .toList();
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: MediaQuery.of(context).size.height * 0.4,
  //                     width: MediaQuery.of(context).size.width * 0.8,
  //                     child: filteredCustomers.isEmpty
  //                         ? const Center(
  //                             child: Text(
  //                               "No matching customers found",
  //                               style: TextStyle(color: Colors.grey),
  //                             ),
  //                           )
  //                         : ListView.builder(
  //                             itemCount: filteredCustomers.length,
  //                             itemBuilder: (context, index) {
  //                               final customer = filteredCustomers[index];
  //                               final isSelected =
  //                                   selectedCustomer == customer.id.toString();
  //                               return ListTile(
  //                                 title:
  //                                     Text(customer.name ?? 'Unknown Customer'),
  //                                 trailing: isSelected
  //                                     ? const Icon(Icons.check,
  //                                         color: Colors.green)
  //                                     : null,
  //                                 tileColor: isSelected
  //                                     ? Colors.green.withOpacity(0.1)
  //                                     : null,
  //                                 onTap: () {
  //                                   Navigator.pop(context);
  //                                   setState(() {
  //                                     selectedCustomer = customer.id.toString();
  //                                     selectedCustomerName = customer.name;
  //                                   });
  //                                   _loadInvoiceDetails(customer.id.toString());
  //                                 },
  //                               );
  //                             },
  //                           ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text("Close"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<dynamic> _showAccountHeadDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            title: const Text("Select Account Head"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search account head...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        dialogSetState(() {
                          filteredHeads = allHeads
                              .where((item) => item.accountName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: allHeads.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Loading account heads..."),
                              ],
                            ),
                          )
                        : filteredHeads.isEmpty
                            ? const Center(
                                child: Text("No matching account heads found",
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.builder(
                                itemCount: filteredHeads.length,
                                itemBuilder: (context, index) {
                                  final head = filteredHeads[index];
                                  final isSelected = staffId == head.accountId;
                                  return ListTile(
                                    title: Text(head.accountName),
                                    trailing: isSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : null,
                                    tileColor: isSelected
                                        ? Colors.green.withOpacity(0.1)
                                        : null,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        staffName = head.accountName;
                                        staffId = head.accountId;
                                      });
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        });
      },
    );
  }

  // Future<dynamic> _showAccountHeadDialog(BuildContext context) {
  //   filteredStaff = List.from(invDetails?.data.staff ?? []);

  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           title: const Text("Select Account Head"),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: TextField(
  //                     autocorrect: false,
  //                     autofocus: true,
  //                     decoration: const InputDecoration(
  //                       hintText: 'Search staff name...',
  //                       prefixIcon: Icon(Icons.search),
  //                       contentPadding: EdgeInsets.all(8),
  //                       border: OutlineInputBorder(),
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         filteredStaff = invDetails!.data.staff
  //                             .where((item) => item.accountName
  //                                 .toLowerCase()
  //                                 .contains(value.toLowerCase()))
  //                             .toList();
  //                       });
  //                     },
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: MediaQuery.of(context).size.height * 0.4,
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   child: filteredStaff.isEmpty
  //                       ? const Center(
  //                           child: Text("No matching staff found",
  //                               style: TextStyle(color: Colors.grey)),
  //                         )
  //                       : ListView.builder(
  //                           itemCount: filteredStaff.length,
  //                           itemBuilder: (context, index) {
  //                             final staff = filteredStaff[index];
  //                             final isSelected = staffId == staff.accountId;
  //                             return ListTile(
  //                               title: Text(staff.accountName),
  //                               trailing: isSelected
  //                                   ? const Icon(Icons.check,
  //                                       color: Colors.green)
  //                                   : null,
  //                               tileColor: isSelected
  //                                   ? Colors.green.withOpacity(0.1)
  //                                   : null,
  //                               onTap: () {
  //                                 Navigator.pop(context);
  //                                 this.setState(() {
  //                                   staffName = staff.accountName;
  //                                   staffId = staff.accountId;
  //                                 });
  //                               },
  //                             );
  //                           },
  //                         ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text("Close"),
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  Widget _rowTotal(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('₹${value.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
