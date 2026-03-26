// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/lead_management/bulkDeleteLeadModel.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/leadSubTypeModel.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/screens/leadManagement/add_followup.dart';
import 'package:login2/widgets/allreportFilterWidet.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../../service/service.dart';

import 'leadDetails.dart';

class AllReportNew extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String? pageName;
  int? page;
  int? pageSize;
  List? checkedCategoryItems;
  List? checkedCategoryItemsName;
  List? checkedCallResultItems;
  List? checkedCallResultItemsName;
  List? checkedPriorityItems;
  List? checkedPriorityItemsName;
  List? checkedAssignedStaffItems;
  List? checkedAssignedStaffItemsName;
  List? checkedCreatedStaffItems;
  List? checkedCreatedStaffItemsName;
  List<StateList>? stateDetails;
  AllReportNew(this.token, this.editLead, this.deleteLead, this.cloudCall,
      {this.pageName,
      this.page,
      this.pageSize,
      this.checkedCategoryItems,
      this.checkedCategoryItemsName,
      this.checkedCallResultItems,
      this.checkedCallResultItemsName,
      this.checkedPriorityItems,
      this.checkedPriorityItemsName,
      this.checkedAssignedStaffItems,
      this.checkedAssignedStaffItemsName,
      this.checkedCreatedStaffItems,
      this.checkedCreatedStaffItemsName,
      super.key});

  @override
  State<AllReportNew> createState() => _AllReportNewState();
}

class _AllReportNewState extends State<AllReportNew> {
  static const Color appBarStart = Color(0xFF2a86c9);
  static const Color appBarEnd = Color(0xFF406dbe);
  static const Color callGreen = Color(0xFF4CAF50);
  static const Color followupBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color borderLight = Color(0xFFECF0F1);
  static const Color backgroundLight = Color.fromARGB(255, 247, 249, 252);

  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  LeadSubTypeModel? leadSubTypeList;
  Map<String, String?> selectedSubCategories = {};
  bool? result = true;
  bool? result1 = true;
  String fromdate = "";
  String todate = "";
  String createdDate = "";
  String updatedDate = "";
  var outputFormat = DateFormat('dd-MM-yyyy');
  bool? isCalled = true;
  List selectedIUsers = [];
  List selectedUserNumbers = [];
  bool isCreatedDateChecked = true;
  bool isUpdatedDateChecked = false;
  bool isFilterApplied = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<dynamic> _filteredItems = [];
  bool _isSelectAll = false;
  bool _isCompactView = false;
  final Set<String> _expandedLeadIds = {};
  bool searchField = false;

  final List<Color> _colors = [
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
  ];
  CommonConfigureModel? configure;
  bool isSort = true;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  TextEditingController stateVal = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController districtVal = TextEditingController();
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  bool isDistrictLoading = false;
  //bool isLoading = false;
  String? StateId;
  String? DistrictId;
  List<dynamic> items = [];
  int page = 1;
  int pageSize = 20;
  bool isLoading = false;
  List checkedCategoryItems = [];
  List checkedCategoryItemsName = [];
  List checkedCallResultItems = [];
  List checkedCallResultItemsName = [];
  List checkedPriorityItems = [];
  List checkedPriorityItemsName = [];
  List checkedAssignedStaffItems = [];
  List checkedAssignedStaffItemsName = [];
  List checkedCreatedStaffItems = [];
  List checkedCreatedStaffItemsName = [];
  List checkedLeadSource = [];
  List checkedLeadSourceName = [];
  String? branch;
  String roleId = '';
  String multiBranch = '';
  StateModel? stateDetails;
  String currentSortOrder = 'desc';
  bool sortAscending = false;
  dynamic leadDetails;
  String? callMasterId;
  String status = 'All';
  @override
  void initState() {
    super.initState();
    getData();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.last.index ==
          items.length - 1) {
        if (items.length < viewLeads!.data.totalLeads) {
          getData();
        }
      }
    });
  }

  Future<StateList?> selectStateDialog(BuildContext context) async {
    return showDialog<StateList>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select State"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: stateDetails?.data.length ?? 0,
              itemBuilder: (context, index) {
                final stateItem = stateDetails!.data[index];
                return ListTile(
                  title: Text(stateItem.name),
                  onTap: () {
                    Navigator.pop(context, stateItem); // return selected state
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> loadPostOffices(String pin) async {
    PostalCodeModel postalCodeModel =
        await HttpService.fetchPostOffice(pin); // your API call
    setState(() {
      postOffices = postalCodeModel.postOffice ?? [];
      if (postOffices.isNotEmpty) {
        selectedPostOffice = postOffices.first;
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _filterItems();
    });
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(items);
    } else {
      _filteredItems = items.where((item) {
        final name = item.clientName?.toLowerCase() ?? '';
        final phone = item.contactNumber1?.toLowerCase() ?? '';
        final staffName = item.staffName?.toLowerCase() ?? '';

        return name.contains(_searchQuery) ||
            phone.contains(_searchQuery) ||
            staffName.contains(_searchQuery);
      }).toList();
    }
  }

  void _toggleSelectAll() {
    setState(() {
      _isSelectAll = !_isSelectAll;

      if (_isSelectAll) {
        // Select all visible items (considering search filter)
        final itemsToSelect = _searchQuery.isEmpty ? items : _filteredItems;
        for (var item in itemsToSelect) {
          if (!item.isSelected) {
            item.isSelected = true;
            if (!selectedIUsers.contains(item.callMasterId)) {
              selectedIUsers.add(item.callMasterId);
              selectedUserNumbers.add(item.contactNumber1);
            }
          }
        }
      } else {
        // Deselect all
        for (var item in items) {
          item.isSelected = false;
        }
        selectedIUsers.clear();
        selectedUserNumbers.clear();
      }
    });
  }

  void _handleLongPress(int index) {
    if (index >= items.length) return;

    setState(() {
      items[index].isSelected = !items[index].isSelected;
      if (items[index].isSelected) {
        if (!selectedIUsers.contains(items[index].callMasterId)) {
          selectedIUsers.add(items[index].callMasterId);
          selectedUserNumbers.add(items[index].contactNumber1);
        }
      } else {
        selectedIUsers.remove(items[index].callMasterId);
        selectedUserNumbers.remove(items[index].contactNumber1);
      }
      _updateSelectAllState();
    });
  }

  void _updateSelectAllState() {
    final visibleItems = _searchQuery.isEmpty ? items : _filteredItems;
    if (visibleItems.isEmpty) {
      _isSelectAll = false;
      return;
    }
    final allSelected = visibleItems.every((item) => item.isSelected);
    setState(() {
      _isSelectAll = allSelected;
    });
  }

  List<Widget> _buildSelectionActions() {
    return [
      InkWell(
        onTap: _toggleSelectAll,
        child: Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                _isSelectAll ? Icons.check_box : Icons.check_box_outline_blank,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 4),
              const Text(
                'All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),

      // Selected count
      CircleAvatar(
        radius: 13,
        backgroundColor: Colors.white,
        child: Text(
          selectedIUsers.length.toString(),
          style: const TextStyle(color: Colors.blue, fontSize: 17),
        ),
      ),
      const SizedBox(width: 15),

      // Delete icon
      InkWell(
        onTap: () {
          if (selectedIUsers.isNotEmpty) {
            _showDeleteConfirmationDialog();
          }
        },
        child: const Icon(Icons.delete, color: Colors.red),
      ),
    ];
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: Text(
              'Are you sure you want to delete ${selectedIUsers.length} selected leads?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performBulkDelete();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

// Add bulk delete method
  Future<void> _performBulkDelete() async {
    Common.showProgressDialog(context, "Deleting leads...");

    try {
      Map<String, dynamic> body = {
        "token": widget.token,
        'leadMasterIds': selectedIUsers,
      };

      BulkDeleteLeadModel deleteBulk = await HttpService.bulkDeleteLead(body);

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (deleteBulk.data == true) {
        Common.toastMessaage(
            '${selectedIUsers.length} lead(s) deleted successfully',
            Colors.green);
        _refreshListAfterDelete();
      } else {
        Common.toastMessaage(deleteBulk.message, Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      Common.toastMessaage("Delete failed: ${e.toString()}", Colors.red);
    }
  }

  void _refreshListAfterDelete() {
    final deletedCount = selectedIUsers.length;

    setState(() {
      selectedIUsers.clear();
      selectedUserNumbers.clear();
      _isSelectAll = false;
      for (var item in items) {
        item.isSelected = false;
      }
    });

    if (viewLeads != null) {
      viewLeads!.data.totalLeads = (viewLeads!.data.totalLeads - deletedCount)
          .clamp(0, double.maxFinite.toInt());
    }

    _reloadCurrentData();
  }

  void _reloadCurrentData() {
    setState(() {
      items.clear();
      page = 1;
      _filteredItems.clear();
      _searchController.clear();
      _searchQuery = '';
    });

    getData();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: AllReportFilterWidget(
                  pageId: 2,
                  initialFilters: {
                    'created_from': DateTime.now()
                        .subtract(const Duration(days: 7))
                        .toIso8601String(),
                    'created_to': DateTime.now().toIso8601String(),
                    'category_ids': <String>[],
                    'from_account_head_ids': <String>[],
                    'to_account_head_ids': <String>[],
                    'created_by_ids': <String>[],
                  },
                  onApplyFilters: (filters) {
                    debugPrint("Filters applied: $filters");
                    // You can assign to currentFilters or reload a list if needed
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void getData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      final connectivityResult = await Connectivity().checkConnectivity();
      result = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);

      roleId = await Common.getSharedPref("roleId") ?? "";
      multiBranch = await Common.getSharedPref("multiBranch") ?? "";
      int createdFlag = 0;
      int updatedFlag = 0;
      if (isFilterApplied) {
        createdFlag = isCreatedDateChecked ? 1 : 0;
        updatedFlag = isUpdatedDateChecked ? 1 : 0;
      }

      Map<String, dynamic> body = {
        "token": widget.token,
        "fromDate":
            fromdate != "" ? outputFormat.format(DateTime.parse(fromdate)) : "",
        "toDate":
            todate != "" ? outputFormat.format(DateTime.parse(todate)) : "",
        "createdDate": createdFlag,
        "updatedDate": updatedFlag,
        "page": page,
        "pageSize": pageSize,
        "callResultId": checkedCallResultItems,
        "leadCategoryId": checkedCategoryItems,
        "priority": checkedPriorityItems,
        "staffId": checkedAssignedStaffItems,
        "createdBy": checkedCreatedStaffItems,
        "branchId": branch,
        "lead_source_id": checkedLeadSource,
        "state": StateId ?? "",
        "district": DistrictId ?? "",
        "sort": currentSortOrder,
      };

      viewLeads = await HttpService.allViewLeads(body);
      if (viewLeads != null) {
        if (page == 1) items.clear();
        setState(() {
          items.addAll(viewLeads!.data.details);
          page++;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }

      if (commonDetails == null) {
        commonDetails = await HttpService.addLeadCommonData(widget.token);
      }
      if (configure == null) {
        configure = await HttpService.configure(widget.token);
      }
      setState(() {});
    }

    loadStates();
  }

  Future<void> loadStates() async {
    var result = await HttpService.getState();
    log("States loaded: ${result?.data.length}");
    setState(() {
      stateDetails = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: _buildAppBar(),
      body: viewLeads != null && configure != null
          ? Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: result!
                      ? items.isNotEmpty
                          ? ScrollablePositionedList.builder(
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
                              itemCount: (_searchQuery.isEmpty
                                      ? items.length
                                      : _filteredItems.length) +
                                  (isLoading ? 1 : 0),
                              padding: const EdgeInsets.only(top: 10),
                              itemBuilder: (context, index) {
                                if (index ==
                                    (_searchQuery.isEmpty
                                        ? items.length
                                        : _filteredItems.length)) {
                                  return _buildLoadingIndicator();
                                }
                                return leadListWidget(context, index);
                              },
                            )
                          : _buildEmptyState()
                      : _buildNoInternetState(),
                ),
              ],
            )
          : _buildShimmerLoading(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appBarStart, appBarEnd],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (selectedIUsers.isNotEmpty)
                      Text(
                        '${selectedIUsers.length} selected',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    else
                      const Text(
                        'All Report',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (selectedIUsers.isEmpty) ...[
                    // View Toggle Button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isCompactView = !_isCompactView;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _isCompactView
                              ? Icons.view_agenda_outlined
                              : Icons.view_headline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    // Sort Button
                    InkWell(
                      onTap: () {
                        setState(() {
                          sortAscending = !sortAscending;
                          currentSortOrder = sortAscending ? 'asc' : 'desc';
                          items.clear();
                          page = 1;
                        });
                        getData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              sortAscending ? 'Oldest' : 'Newest',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Filter Button
                    InkWell(
                      onTap: () {
                        fromdate = "";
                        todate = "";
                        filtrationSheet(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Image.asset("assets/icons/filter.png",
                            width: 20, color: Colors.white),
                      ),
                    ),
                  ] else
                    ..._buildSelectionActions(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Leads Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        color: appBarStart, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Total Leads : ${viewLeads?.data.totalLeads ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Search Toggle
              InkWell(
                onTap: () {
                  setState(() {
                    searchField = !searchField;
                    if (!searchField) {
                      _searchController.clear();
                      _searchQuery = '';
                      _filterItems();
                    }
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: searchField ? appBarStart : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: searchField ? appBarStart : borderLight,
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      searchField ? Icons.close_rounded : Icons.search_rounded,
                      color: searchField ? Colors.white : appBarStart,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (searchField)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                    _filterItems();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, phone or staff...',
                  hintStyle: TextStyle(
                      color: textSecondary.withOpacity(0.5), fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: appBarStart, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _filterItems();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        if (fromdate != "" && todate != "")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: appBarStart.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: appBarStart),
                  const SizedBox(width: 8),
                  Text(
                    '${outputFormat.format(DateTime.parse(fromdate))} to ${outputFormat.format(DateTime.parse(todate))}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: appBarStart,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(appBarStart),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/empty.json', height: 200),
          const Text(
            'No leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 80, color: textSecondary),
          const SizedBox(height: 16),
          const Text(
            'No internet connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
          ElevatedButton(
            onPressed: getData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget leadListWidget(BuildContext context, int index) {
    final item = _searchQuery.isEmpty ? items[index] : _filteredItems[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onLongPress: () => _handleLongPress(index),
        onTap: () => _redirectToDetails(item),
        child: Container(
          decoration: BoxDecoration(
            color:
                item.isSelected ? appBarStart.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  item.isSelected ? appBarStart.withOpacity(0.3) : borderLight,
              width: item.isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLeadHeader(item),
              if (!_isCompactView ||
                  _expandedLeadIds.contains(item.callMasterId.toString()))
                _buildLeadDetails(item),
              _buildLeadFooter(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadHeader(item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: item.priority == '3'
                  ? accentRed
                  : (item.priority == '2' ? callGreen : Colors.grey),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.clientName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          decoration: item.priority == '4'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isCustomer)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: callGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Customer',
                            style: TextStyle(
                                color: callGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.contactNumber1 ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Category Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appBarStart.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.leadCategory ?? 'General',
              style: const TextStyle(
                  color: appBarStart,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadDetails(item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.withOpacity(0.02),
      child: Column(
        children: [
          _buildDetailRow(Icons.person_outline, 'Assigned to',
              item.staffName ?? 'Unassigned'),
          _buildDetailRow(Icons.calendar_today_outlined, 'Followup Date',
              item.scheduledDate ?? '--'),
          _buildDetailRow(Icons.phone_callback_outlined, 'Called Date',
              item.isCalled ? (item.calledDate ?? '--') : 'Not Called'),
          if (item.address != null && item.address.toString().isNotEmpty)
            _buildDetailRow(
                Icons.location_on_outlined, 'Address', item.address),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textSecondary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  color: textPrimary,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadFooter(item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: borderLight, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Response Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  (item.callResultId >= 0 && item.callResultId < _colors.length
                          ? _colors[item.callResultId]
                          : accentOrange)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.callResult ?? 'New',
              style: TextStyle(
                color:
                    item.callResultId >= 0 && item.callResultId < _colors.length
                        ? _colors[item.callResultId]
                        : accentOrange,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Right: Quick Actions
          Row(
            children: [
              _buildMiniActionButton(
                icon: Icons.call,
                color: callGreen,
                isEnabled: selectedIUsers.isEmpty,
                onTap: () => widget.cloudCall
                    ? chooseCallDialog(context, items.indexOf(item))
                    : Common.dialPad(item.contactNumber1),
              ),
              const SizedBox(width: 8),
              _buildMiniActionButton(
                icon: Icons.add_task_rounded,
                color: followupBlue,
                isEnabled: selectedIUsers.isEmpty,
                onTap: () {
                  if (item.callResult != "Confirmed") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFollowup(
                          widget.token,
                          widget.editLead,
                          widget.deleteLead,
                          widget.cloudCall,
                          item.callMasterId.toString(),
                          pageName: widget.pageName,
                          leadType: item.leadCategory,
                          leadTypeId: item.leadCategoryId.toString(),
                          leadType1: item.leadCategory,
                          leadSubType: item.leadSubCategory,
                          leadSubTypeId: item.leadSubCategoryId.toString(),
                          priorityId: item.priority.toString(),
                          priority: item.priorityName,
                          cost: item.cost.toString(),
                          address: item.address,
                        ),
                      ),
                    ).then((value) => _reloadCurrentData());
                  } else {
                    Common.toastMessaage(
                        "Cannot follow up confirmed leads", Colors.red);
                  }
                },
              ),
              if (_isCompactView) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (_expandedLeadIds
                          .contains(item.callMasterId.toString())) {
                        _expandedLeadIds.remove(item.callMasterId.toString());
                      } else {
                        _expandedLeadIds.add(item.callMasterId.toString());
                      }
                    });
                  },
                  child: Icon(
                    _expandedLeadIds.contains(item.callMasterId.toString())
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _redirectToDetails(item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeadDetails(
          widget.token!,
          widget.editLead,
          widget.deleteLead,
          widget.cloudCall,
          item.callMasterId.toString(),
          pageName: widget.pageName.toString(),
          page: page,
          pageSize: page * pageSize,
          fromDate: fromdate.toString(),
          toDate: todate.toString(),
        ),
      ),
    ).then((r) => _reloadCurrentData());
  }

  void chooseCallDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Call Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_done, color: appBarStart),
                title: const Text('Cloud Call'),
                onTap: () async {
                  Navigator.pop(context);
                  _makeCloudCall(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android, color: callGreen),
                title: const Text('Sim Call'),
                onTap: () {
                  Navigator.pop(context);
                  Common.dialPad(items[index].contactNumber1);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makeCloudCall(int index) async {
    Common.showProgressDialog(context, "Initiating Cloud Call...");
    try {
      CloudCallModel? cloudCall = await HttpService.addCloudCall(
          widget.token,
          items[index].callMasterId.toString(),
          items[index].contactNumber1.toString());
      if (context.mounted) Navigator.pop(context);
      if (cloudCall?.data == true) {
        Common.toastMessaage("Call initiated", Colors.green);
      } else {
        Common.toastMessaage(
            cloudCall?.message ?? "Failed to initiate call", Colors.red);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      Common.toastMessaage("Error: $e", Colors.red);
    }
  }

  void filtrationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Filter by Date",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: isCreatedDateChecked,
                            title: const Text("Created Date"),
                            onChanged: (val) {
                              setModalState(() {
                                isCreatedDateChecked = true;
                                isUpdatedDateChecked = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: isUpdatedDateChecked,
                            title: const Text("Updated Date"),
                            onChanged: (val) {
                              setModalState(() {
                                isCreatedDateChecked = false;
                                isUpdatedDateChecked = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DateTimePicker(
                            initialValue: fromdate,
                            firstDate: DateTime(2000),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            dateLabelText: 'From Date',
                            onChanged: (val) => fromdate = val,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DateTimePicker(
                            initialValue: todate,
                            firstDate: DateTime(2000),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            dateLabelText: 'To Date',
                            onChanged: (val) => todate = val,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appBarStart,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        isFilterApplied = true;
                        _reloadCurrentData();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters',
                          style: TextStyle(color: Colors.white)),
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
