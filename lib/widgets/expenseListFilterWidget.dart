import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/exp_master_data.dart';
import 'package:login2/service/service.dart';

class ExpenseListFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final int pageId;
  final Map<String, dynamic>? initialFilters;

  const ExpenseListFilterWidget({
    super.key,
    required this.onApplyFilters,
    required this.pageId,
    this.initialFilters,
  });

  @override
  State<ExpenseListFilterWidget> createState() =>
      _ExpenseListFilterWidgetState();
}

class _ExpenseListFilterWidgetState extends State<ExpenseListFilterWidget> {
  String selectedCategory = 'Category';
  DateTime? createdFrom;
  DateTime? createdTo;
  List<AccountHead> allAccountHeads = [];
  List<StaffList> staffs = [];
  List<ExpenseType> filteredCategories = [];
  Set<String> selectedFromAccountHeadIds = {};
  Set<String> selectedToAccountHeadIds = {};
  Set<String> selectedCategoryIds = {};
  Set<String> selectedCreatedByIds = {};

  // Track original order of items
  Map<String, List<String>> originalOrder = {
    'category_ids': [],
    'from_account_head_ids': [],
    'to_account_head_ids': [],
    'created_by_ids': [],
  };

  // Track if we should sort selected items to top
  bool shouldSortSelectedToTop = false;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    createdFrom = widget.initialFilters?['created_from'] != null
        ? DateTime.parse(widget.initialFilters!['created_from'])
        : DateTime(now.year, now.month, 1);
    createdTo = widget.initialFilters?['created_to'] != null
        ? DateTime.parse(widget.initialFilters!['created_to'])
        : DateTime(now.year, now.month + 1, 0);

    selectedCategoryIds = widget.initialFilters?['category_ids'] != null
        ? Set.from(widget.initialFilters!['category_ids'])
        : <String>{};

    selectedFromAccountHeadIds =
        widget.initialFilters?['from_account_head_ids'] != null
            ? Set.from(widget.initialFilters!['from_account_head_ids'])
            : <String>{};

    selectedToAccountHeadIds =
        widget.initialFilters?['to_account_head_ids'] != null
            ? Set.from(widget.initialFilters!['to_account_head_ids'])
            : <String>{};

    selectedCreatedByIds = widget.initialFilters?['created_by_ids'] != null
        ? Set.from(widget.initialFilters!['created_by_ids'])
        : <String>{};

    shouldSortSelectedToTop = widget.initialFilters != null;
    _loadData();
  }

  Future<void> _loadData() async {
    final masterData = await HttpService.expenseMasterData();
    if (mounted && masterData != null && masterData.status) {
      setState(() {
        allAccountHeads = masterData.data.accountHead;
        staffs = masterData.data.staffList;
        filteredCategories = masterData.data.expenseType;

        // Store original order
        originalOrder['category_ids'] =
            filteredCategories.map((e) => e.expCatId).toList();
        originalOrder['from_account_head_ids'] =
            allAccountHeads.map((e) => e.accountId).toList();
        originalOrder['to_account_head_ids'] =
            allAccountHeads.map((e) => e.accountId).toList();
        originalOrder['created_by_ids'] = staffs.map((e) => e.userId).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilterBody(),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE4E9F2), height: 1),
          const SizedBox(height: 16),
          _buildApplyButton(),
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
            fontSize: 22,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterCategories(),
          const SizedBox(width: 16),
          Expanded(child: _buildFilterOptionsPanel()),
        ],
      ),
    );
  }

  Widget _buildFilterCategories() {
    final categories = [
      'Category',
      'From Account',
      'To Account',
      'Transaction Date',
      'Created By'
    ];

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories
            .map((title) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _buildFilterCategory(
                    title,
                    title == 'Transaction Date'
                        ? Icons.date_range
                        : Icons.account_circle,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFilterCategory(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    final hasFilters = _hasFiltersForCategory(title);

    return GestureDetector(
      onTap: () {
        _searchController.clear();
        setState(() => selectedCategory = title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3366FF)),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  if (hasFilters)
                    Positioned(
                      right: 0,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasFiltersForCategory(String category) {
    switch (category) {
      case 'Category':
        return selectedCategoryIds.isNotEmpty;
      case 'From Account':
        return selectedFromAccountHeadIds.isNotEmpty;
      case 'To Account':
        return selectedToAccountHeadIds.isNotEmpty;
      case 'Transaction Date':
        return createdFrom != null || createdTo != null;
      case 'Created By':
        return selectedCreatedByIds.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildFilterOptionsPanel() {
    switch (selectedCategory) {
      case 'Transaction Date':
        return Column(
          children: [
            _buildDateField(
                "From", createdFrom, (d) => setState(() => createdFrom = d)),
            const SizedBox(height: 30),
            _buildDateField(
                "To", createdTo, (d) => setState(() => createdTo = d)),
          ],
        );

      case 'Created By':
        return _buildSearchableCheckboxList<StaffList>(
          items: staffs,
          getId: (item) => item.userId,
          getLabel: (item) => item.staffName,
          selectedIds: selectedCreatedByIds,
          orderKey: 'created_by_ids',
          hintText: "Search Staff",
        );

      case 'Category':
        return _buildSearchableCheckboxList<ExpenseType>(
          items: filteredCategories,
          getId: (item) => item.expCatId,
          getLabel: (item) => item.expCatName,
          selectedIds: selectedCategoryIds,
          orderKey: 'category_ids',
          hintText: "Search Category",
        );

      case 'From Account':
        return _buildSearchableCheckboxList<AccountHead>(
          items: allAccountHeads,
          getId: (item) => item.accountId,
          getLabel: (item) => item.accountName,
          selectedIds: selectedFromAccountHeadIds,
          orderKey: 'from_account_head_ids',
          hintText: "Search Account Head",
        );

      case 'To Account':
        return _buildSearchableCheckboxList<AccountHead>(
          items: allAccountHeads,
          getId: (item) => item.accountId,
          getLabel: (item) => item.accountName,
          selectedIds: selectedToAccountHeadIds,
          orderKey: 'to_account_head_ids',
          hintText: "Search Account Head",
        );

      default:
        return const Text("Coming soon...");
    }
  }

  Widget _buildSearchableCheckboxList<T>({
    required List<T> items,
    required String Function(T) getId,
    required String Function(T) getLabel,
    required Set<String> selectedIds,
    required String orderKey,
    required String hintText,
  }) {
    final searchTerm = _searchController.text.toLowerCase();

    // First filter items based on search term
    List<T> filteredItems = items.where((item) {
      return getLabel(item).toLowerCase().contains(searchTerm);
    }).toList();

    // If we should sort selected to top, create a new list with selected first
    if (shouldSortSelectedToTop) {
      allAccountHeads = _sortSelectedToTop(
          allAccountHeads,
          selectedFromAccountHeadIds,
          'from_account_head_ids',
          (a) => a.accountId);
      allAccountHeads = _sortSelectedToTop(allAccountHeads,
          selectedToAccountHeadIds, 'to_account_head_ids', (a) => a.accountId);
      staffs = _sortSelectedToTop(
          staffs, selectedCreatedByIds, 'created_by_ids', (s) => s.userId);
      filteredCategories = _sortSelectedToTop(filteredCategories,
          selectedCategoryIds, 'category_ids', (c) => c.expCatId);
    } else {
      // Maintain original order if we shouldn't sort selected to top
      filteredItems.sort((a, b) {
        final aIndex = originalOrder[orderKey]!.indexOf(getId(a));
        final bIndex = originalOrder[orderKey]!.indexOf(getId(b));
        return aIndex.compareTo(bIndex);
      });
    }

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFC5CEE0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final id = getId(item);
              final label = getLabel(item);
              final isSelected = selectedIds.contains(id);

              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
                visualDensity: VisualDensity.compact,
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedIds.add(id);
                    } else {
                      selectedIds.remove(id);
                    }
                  });
                },
                title: Text(label, style: const TextStyle(fontSize: 13)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, DateTime? value, Function(DateTime) onSelect) {
    final display = value != null ? _formatter.format(value) : 'Select';
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Color(0xFF3366FF)),
          const SizedBox(width: 8),
          Text(
            '$label: $display',
            style: const TextStyle(fontSize: 14, color: Color(0xFF2E3A59)),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
List<T> _sortSelectedToTop<T>(
  List<T> items,
  Set<String> selectedIds,
  String orderKey,
  String Function(T) getId
) {
  final selectedItems = items.where((item) => selectedIds.contains(getId(item))).toList();
  final unselectedItems = items.where((item) => !selectedIds.contains(getId(item))).toList();

  selectedItems.sort((a, b) =>
    originalOrder[orderKey]!.indexOf(getId(a)).compareTo(
      originalOrder[orderKey]!.indexOf(getId(b))
    )
  );
  unselectedItems.sort((a, b) =>
    originalOrder[orderKey]!.indexOf(getId(a)).compareTo(
      originalOrder[orderKey]!.indexOf(getId(b))
    )
  );

  return [...selectedItems, ...unselectedItems];
}

  void _applyFilters() {
    setState(() {
      shouldSortSelectedToTop = true;
    });
    widget.onApplyFilters({
      'created_from': createdFrom?.toIso8601String(),
      'created_to': createdTo?.toIso8601String(),
      'from_account_head_ids': selectedFromAccountHeadIds.toList(),
      'to_account_head_ids': selectedToAccountHeadIds.toList(),
      'category_ids': selectedCategoryIds.toList(),
      'created_by_ids': selectedCreatedByIds.toList(),
    });
    Navigator.pop(context);
  }
}
