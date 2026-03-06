import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/leadProductsModel.dart';

class ViewLeadsFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final AddLeadCommonDataModel? commonDetails;
  final LeadProductSectionModel? productSectionModel;
  final String? currentTab;
  final Map<String, dynamic>? initialFilters;

  const ViewLeadsFilterWidget({
    super.key,
    required this.onApplyFilters,
    this.commonDetails,
    this.productSectionModel,
    this.currentTab,
    this.initialFilters,
  });

  @override
  State<ViewLeadsFilterWidget> createState() => _ViewLeadsFilterWidgetState();
}

class _ViewLeadsFilterWidgetState extends State<ViewLeadsFilterWidget> {
  String selectedCategory = 'Leads Date';

  // Filter states
  DateTime? fromDate;
  DateTime? toDate;
  Set<String> selectedStatusIds = {};
  Set<String> selectedStaffIds = {};
  Set<String> selectedCategoryIds = {};
  Set<String> selectedPriorityIds = {};
  Set<String> selectedProductIds = {};

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialFilters();
  }

  void _loadInitialFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;

      if (filters['fromDate'] != null) {
        fromDate = filters['fromDate'] is DateTime
            ? filters['fromDate']
            : DateTime.tryParse(filters['fromDate'].toString());
      }
      if (filters['toDate'] != null) {
        toDate = filters['toDate'] is DateTime
            ? filters['toDate']
            : DateTime.tryParse(filters['toDate'].toString());
      }

      if (filters['statusIds'] != null) {
        selectedStatusIds = Set<String>.from(filters['statusIds']);
      }
      if (filters['staffIds'] != null) {
        selectedStaffIds = Set<String>.from(filters['staffIds']);
      }
      if (filters['categoryIds'] != null) {
        selectedCategoryIds = Set<String>.from(filters['categoryIds']);
      }
      if (filters['priorityIds'] != null) {
        selectedPriorityIds = Set<String>.from(filters['priorityIds']);
      }
      if (filters['productIds'] != null) {
        selectedProductIds = Set<String>.from(filters['productIds']);
      }
    }

    // Set default dates if null
    if (fromDate == null) {
      fromDate = DateTime.now().subtract(const Duration(days: 30));
    }
    if (toDate == null) {
      toDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilterBody(),
          const SizedBox(height: 24),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2E3A59)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFilterBody() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Categories
          Container(
            width: 120,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE4E9F2))),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryItem('Leads Date', Icons.calendar_today),
                  if (widget.currentTab != 'New')
                    _buildCategoryItem('Stages', Icons.info_outline),
                  _buildCategoryItem('Assigned Staff', Icons.people_outline),
                  _buildCategoryItem('Category', Icons.category_outlined),
                  _buildCategoryItem('Priority', Icons.low_priority),
                  _buildCategoryItem('Products', Icons.shopping_bag_outlined),
                ],
              ),
            ),
          ),
          // Right Side: Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildOptionsExpansion(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    final hasFilters = _hasFiltersForCategory(title);

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: Colors.blue, width: 3))
              : null,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(icon,
                    color: isSelected ? Colors.blue : const Color(0xFF8F9BB3),
                    size: 24),
                if (hasFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.blue : const Color(0xFF8F9BB3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasFiltersForCategory(String category) {
    switch (category) {
      case 'Leads Date':
        return true; // Always has some range
      case 'Stages':
        return selectedStatusIds.isNotEmpty;
      case 'Assigned Staff':
        return selectedStaffIds.isNotEmpty;
      case 'Category':
        return selectedCategoryIds.isNotEmpty;
      case 'Priority':
        return selectedPriorityIds.isNotEmpty;
      case 'Products':
        return selectedProductIds.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildOptionsExpansion() {
    switch (selectedCategory) {
      case 'Leads Date':
        return _buildDateOptions();
      case 'Stages':
        return _buildStatusOptions();
      case 'Assigned Staff':
        return _buildStaffOptions();
      case 'Category':
        return _buildLeadCategoryOptions();
      case 'Priority':
        return _buildPriorityOptions();
      case 'Products':
        return _buildProductOptions();
      default:
        return const Center(child: Text('Select a category'));
    }
  }

  Widget _buildDateOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Date Range',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 16),
        _buildDateField(
            'From Date', fromDate, (date) => setState(() => fromDate = date)),
        const SizedBox(height: 12),
        _buildDateField(
            'To Date', toDate, (date) => setState(() => toDate = date)),
        const SizedBox(height: 16),
        _buildQuickDateFilters(
          onToday: () {
            final now = DateTime.now();
            setState(() {
              fromDate = now;
              toDate = now;
            });
          },
          onThisMonth: () {
            final now = DateTime.now();
            setState(() {
              fromDate = DateTime(now.year, now.month, 1);
              toDate = DateTime(now.year, now.month + 1, 0);
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickDateFilters({
    required VoidCallback onToday,
    required VoidCallback onThisMonth,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              "Today",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onThisMonth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              "This Month",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDateField(
      String label, DateTime? value, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E9F2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF8F9BB3))),
                Text(value != null ? _formatter.format(value) : 'Select Date',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.callResult;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.callResultId.toString(), 'name': e.callResult})
          .toList(),
      selectedIds: selectedStatusIds,
      onToggle: (id) => setState(() => selectedStatusIds.contains(id)
          ? selectedStatusIds.remove(id)
          : selectedStatusIds.add(id)),
    );
  }

  Widget _buildStaffOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.staff;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.userId.toString(), 'name': e.staffName})
          .toList(),
      selectedIds: selectedStaffIds,
      onToggle: (id) => setState(() => selectedStaffIds.contains(id)
          ? selectedStaffIds.remove(id)
          : selectedStaffIds.add(id)),
    );
  }

  Widget _buildLeadCategoryOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.leadCategory;
    return _buildSelectionList(
      items: items
          .map((e) =>
              {'id': e.leadCategoryId.toString(), 'name': e.leadCategory})
          .toList(),
      selectedIds: selectedCategoryIds,
      onToggle: (id) => setState(() => selectedCategoryIds.contains(id)
          ? selectedCategoryIds.remove(id)
          : selectedCategoryIds.add(id)),
    );
  }

  Widget _buildPriorityOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.priority;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.priorityId.toString(), 'name': e.priority})
          .toList(),
      selectedIds: selectedPriorityIds,
      onToggle: (id) => setState(() => selectedPriorityIds.contains(id)
          ? selectedPriorityIds.remove(id)
          : selectedPriorityIds.add(id)),
    );
  }

  Widget _buildProductOptions() {
    if (widget.productSectionModel == null)
      return const Center(child: Text('Loading...'));
    final items = widget.productSectionModel!.data ?? [];
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.id.toString(), 'name': e.productName ?? ''})
          .toList(),
      selectedIds: selectedProductIds,
      onToggle: (id) => setState(() => selectedProductIds.contains(id)
          ? selectedProductIds.remove(id)
          : selectedProductIds.add(id)),
    );
  }

  Widget _buildSelectionList({
    required List<Map<String, String>> items,
    required Set<String> selectedIds,
    required Function(String) onToggle,
  }) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final name = item['name'] ?? '';
              final id = item['id'] ?? '';

              if (_searchController.text.isNotEmpty &&
                  !name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) {
                return const SizedBox.shrink();
              }

              final isSelected = selectedIds.contains(id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => onToggle(id),
                title: Text(name, style: const TextStyle(fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                selectedStatusIds.clear();
                selectedStaffIds.clear();
                selectedCategoryIds.clear();
                selectedPriorityIds.clear();
                selectedProductIds.clear();
                fromDate = DateTime.now().subtract(const Duration(days: 30));
                toDate = DateTime.now();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFE4E9F2)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All',
                style: TextStyle(color: Color(0xFF2E3A59))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters({
                'fromDate': fromDate,
                'toDate': toDate,
                'statusIds': selectedStatusIds.toList(),
                'staffIds': selectedStaffIds.toList(),
                'categoryIds': selectedCategoryIds.toList(),
                'priorityIds': selectedPriorityIds.toList(),
                'productIds': selectedProductIds.toList(),
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply Filters',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
