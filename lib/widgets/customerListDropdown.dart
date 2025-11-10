import 'package:flutter/material.dart';
import 'package:login2/models/clients/customerListModel.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/service/service.dart';

class CustomerSearchBox extends StatefulWidget {
  final String token;
  const CustomerSearchBox({super.key, required this.token});

  @override
  State<CustomerSearchBox> createState() => _CustomerSearchBoxState();
}

class _CustomerSearchBoxState extends State<CustomerSearchBox> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _searchResults = [];
  bool _isSearching = false;
  bool _showList = false;

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showList = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showList = true;
    });

    try {
      final result = await HttpService.customerList(widget.token);
      final List<Customer> allCustomers = result.data ?? [];
      final List<Customer> filtered = allCustomers
          .where((c) =>
              (c.name ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (c.contactNo ?? '').contains(query))
          .toList();

      setState(() {
        _searchResults = filtered;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      debugPrint("Error while searching: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 2, 
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 236, 236),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: searchCustomers,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: "Search Customer...",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 29, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          if (_showList)
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : _searchResults.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No customers found"),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final customer = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.person_outline, color: Colors.grey),
                              title: Text(customer.name ?? ''),
                              subtitle: Text(customer.contactNo ?? ''),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() => _showList = false);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientDetails(
                                      widget.token,
                                      customer.id.toString(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }
}
