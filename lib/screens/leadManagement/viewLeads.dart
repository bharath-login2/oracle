import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:login2/models/clients/postalCodeModel.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/models/lead_management/districtModel.dart';
import 'package:login2/models/lead_management/fileManagerPermissionModel.dart';
import 'package:login2/models/lead_management/leadDetailsModel.dart';
import 'package:login2/models/lead_management/leadDetailsModelAdd.dart';
import 'package:login2/models/lead_management/leadMileStoneListModel.dart';
import 'package:login2/models/lead_management/listFolderName.dart';
import 'package:login2/models/lead_management/stateModel.dart';
import 'package:login2/screens/leadManagement/add_followup.dart';
import 'package:login2/screens/leadManagement/minimalLeadDetails.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/lead_management/BulkTransferLeadModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../models/lead_management/bulkDeleteLeadModel.dart';
import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../bottom_navigation_bar.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/leadManagement/leadDetails.dart';
import '../../service/service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ignore: must_be_immutable
class ViewLeads extends StatefulWidget {
  String? token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String? fromDate;
  String? toDate;
  String? status;
  String? category;
  String? staff;
  String? categoryName;
  String? staffName;
  String? pageName;
  bool? isCalled;
  int? scrollToIndex;
  int? page;
  int? pageSize;
  String? leadType;
  String? callStatus;
  String? callResId;
  String? callResName;
  DateTime? preservedFromDate;
  DateTime? preservedToDate;
  String? preservedSortOrder;
  bool? preservedSortAscending;
  List<String>? preservedCategoryItems;
  List<String>? preservedPriorityItems;
  List<String>? preservedAssignedStaffItems;
  List<String>? preservedResponseItems;
  List<StateList>? stateDetails;

  ViewLeads(
    this.token,
    this.editLead,
    this.deleteLead,
    this.cloudCall, {
    super.key,
    this.fromDate,
    this.toDate,
    this.status,
    this.category,
    this.staff,
    this.pageName,
    this.isCalled,
    this.scrollToIndex,
    this.page,
    this.pageSize,
    this.leadType,
    this.categoryName,
    this.staffName,
    this.callStatus,
    this.callResId,
    this.callResName,
    this.preservedFromDate,
    this.preservedToDate,
    this.preservedSortOrder,
    this.preservedSortAscending,
    this.preservedCategoryItems,
    this.preservedPriorityItems,
    this.preservedAssignedStaffItems,
    this.preservedResponseItems,
  });

  @override
  State<ViewLeads> createState() => _ViewLeadsState();
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewLeads &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          pageName == other.pageName;

  @override
  int get hashCode => Object.hash(token, pageName);
}

class _ViewLeadsState extends State<ViewLeads>
    with AutomaticKeepAliveClientMixin {
  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  CommonConfigureModel? configure;
  LeadDeatailsModel? leadDetails;
  LeadDeatailsModelAdd? leadDetailsAdditional;
  StateModel? stateDetails;
  LeadMileStoneListModel? mileStone;
  ListFolderNameModel? listFolder;
  FileManagerPermissionModel? fileManagerPermission;
  bool? result = true;
  bool? result1 = true;
  DateTime? fromdate;
  DateTime? todate;
  String currentSortOrder = 'desc';
  bool sortAscending = false;
  // var outputFormat = DateFormat('dd-MM-yyyy');
  var outputFormat = DateFormat('yyyy-MM-dd');
  dynamic status;
  dynamic staff;
  dynamic priority;
  bool? isCalled = true;
  List selectedIUsers = [];
  List selectedUserNumbers = [];
  bool searchField = false;
  String callMasterId = "";
  String whatsappNo = '';
  String whatsappNo1 = '';
  TextEditingController contactFName = TextEditingController();
  TextEditingController contactLName = TextEditingController();
  TextEditingController contactMobile = TextEditingController();
  TextEditingController stateVal = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController districtVal = TextEditingController();
  PostalCodeModel? postalCodeModel;
  List<PostOffice> postOffices = [];
  List<DistrictList> districtList = [];
  PostOffice? selectedPostOffice;
  bool isDistrictLoading = false;
  bool _isLoading = false;
  String? StateId;
  String? DistrictId;
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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  static final Map<String, Map<int, List<Detail>>> _leadCache = {};
  static final Map<String, int> _cacheTotalCounts = {};
  String? _currentCacheKey;
  List<Detail> items = [];
  int page = 1;
  int pageSize = 10;
  bool isLoading = false;
  bool isInitialLoad = true;
  bool timeOut = false;
  List checkedResponseItems = [];
  List checkedresponseItemsName = [];
  List checkedCategoryItems = [];
  List checkedCategoryItemsName = [];
  List checkedPriorityItems = [];
  List checkedPriorityItemsName = [];
  List checkedAssignedStaffItems = [];
  List checkedAssignedStaffItemsName = [];
  List<TransferStaff> filteredStaff = [];
  String staffId = "";
  String staffName = "Staff";
  String name = '';
  String userId = '';
  String statusWise = '';
  String statusWiseId = '';
  String statusCatId = '';
  String type = '';
  String? branch;
  String roleId = '';
  String multiBranch = '';
  String transferPermission = '';
  String phoneCallLogPermission = '';
  CommonResponse? loginOrNot;
  bool _isDataLoaded = false;
  String? _lastApiCallHash;

  @override
  void initState() {
    super.initState();
    _initializeData();
    initListner();
    loadStates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreFromCache();
    });
  }

  void _restoreFromCache() {
    final cacheKey = _generateCacheKey();
    if (_leadCache.containsKey(cacheKey) && items.isEmpty) {
      final cachedPages = _leadCache[cacheKey]!;
      final allItems = <Detail>[];
      final sortedKeys = cachedPages.keys.toList()..sort();
      for (var pageNum in sortedKeys) {
        allItems.addAll(cachedPages[pageNum]!);
      }

      setState(() {
        items.addAll(allItems);
        page = cachedPages.keys.length + 1;
      });
    }
  }

  void _initializeData() {
    fromdate = widget.preservedFromDate ??
        (widget.fromDate != null ? DateTime.parse(widget.fromDate!) : null);
    todate = widget.preservedToDate ??
        (widget.toDate != null ? DateTime.parse(widget.toDate!) : null);
    currentSortOrder = widget.preservedSortOrder ?? 'desc';
    sortAscending = widget.preservedSortAscending ?? false;
    _initializeFilterItems();
    if (widget.page != null) page = widget.page! - 1;
    if (widget.pageSize != null) pageSize = widget.pageSize!;
    status = widget.status == "0" ? null : widget.status;
    staff = widget.staff;
    _handlePageSpecificLogic();
    if (!_isDataLoaded) {
      getData(currentSortOrder, true, status);
    }
  }

  void _initializeFilterItems() {
    if (widget.preservedCategoryItems != null) {
      checkedCategoryItems = List.from(widget.preservedCategoryItems!);
    }
    if (widget.preservedPriorityItems != null) {
      checkedPriorityItems = List.from(widget.preservedPriorityItems!);
    }
    if (widget.preservedAssignedStaffItems != null) {
      checkedAssignedStaffItems =
          List.from(widget.preservedAssignedStaffItems!);
    }
    if (widget.preservedResponseItems != null) {
      checkedResponseItems = List.from(widget.preservedResponseItems!);
    }
    if (widget.staff != null) {
      checkedAssignedStaffItems.add(widget.staff!);
      checkedAssignedStaffItemsName.add(widget.staffName!);
    }
    if (widget.category != null) {
      checkedCategoryItems.add(widget.category!);
      checkedCategoryItemsName.add(widget.categoryName!);
    }
    if (widget.callResId != null) {
      checkedResponseItems.add(widget.callResId!);
      checkedresponseItemsName.add(widget.callResName!);
    }
  }

  void _handlePageSpecificLogic() {
    if (widget.pageName == "Followup Leads") {
      isCalled = false;
      fromdate =
          widget.fromDate != null ? DateTime.parse(widget.fromDate!) : null;
    } else if (widget.pageName == "Closed Leads" ||
        widget.pageName == "Total Called" ||
        widget.pageName == "Rejected Leads") {
      fromdate =
          widget.fromDate != null ? DateTime.parse(widget.fromDate!) : null;
      todate = widget.toDate != null ? DateTime.parse(widget.toDate!) : null;
    }
  }

  String _generateApiCallHash() {
    return '$fromdate$todate$status${checkedCategoryItems.join()}${checkedResponseItems.join()}${checkedAssignedStaffItems.join()}${checkedPriorityItems.join()}$currentSortOrder$page$pageSize$branch$StateId$DistrictId';
  }

  Future<void> loadStates() async {
    if (stateDetails == null) {
      var result = await HttpService.getState();
      log("States loaded: ${result?.data.length}");
      setState(() {
        stateDetails = result;
      });
    }
  }

  // void initListner() {
  //   itemPositionsListener.itemPositions.addListener(() {
  //     if (itemPositionsListener.itemPositions.value.last.index ==
  //         items.length - 1) {
  //       if (items.length < (viewLeads?.data.totalLeads ?? 0)) {
  //         getData(currentSortOrder, false, status);
  //       }
  //     }
  //   });
  // }

  void initListner() {
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;
      final lastIndex = positions.last.index;
      if (lastIndex >= items.length - 3 && !isLoading) {
        final cacheKey = _generateCacheKey();
        final totalLeads =
            _cacheTotalCounts[cacheKey] ?? viewLeads?.data.totalLeads ?? 0;
        if (items.length < totalLeads) {
          final nextPage = (items.length ~/ pageSize) + 1;
          if (_leadCache.containsKey(cacheKey) &&
              _leadCache[cacheKey]!.containsKey(nextPage)) {
            final cachedItems = _leadCache[cacheKey]![nextPage]!;
            setState(() {
              items.addAll(cachedItems);
            });
          } else {
            getData(currentSortOrder, false, status);
          }
        }
      }
    });
  }

  String _generateCacheKey() {
    return '$fromdate$todate$status${checkedCategoryItems.join()}'
        '${checkedResponseItems.join()}${checkedAssignedStaffItems.join()}'
        '${checkedPriorityItems.join()}$currentSortOrder$branch$StateId$DistrictId';
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
                    Navigator.pop(context, stateItem);
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
    PostalCodeModel postalCodeModel = await HttpService.fetchPostOffice(pin);
    setState(() {
      postOffices = postalCodeModel.postOffice ?? [];
      if (postOffices.isNotEmpty) {
        selectedPostOffice = postOffices.first;
      }
    });
  }

  Future<void> listFolderList(
      String token, String callMasterId, String path) async {
    if (listFolder == null) {
      listFolder =
          await HttpService.listFolderAndFiles(token, callMasterId, path);
      if (listFolder != null) {
        fileManagerPermissionFunction(token);
        setState(() {});
      }
    }
  }

  Future<void> fileManagerPermissionFunction(String token) async {
    if (fileManagerPermission == null) {
      fileManagerPermission = await HttpService.fileManagerPermission(token);
      setState(() {});
    }
  }

  Future<void> listMileStone(String token, String callMasterId) async {
    if (mileStone == null) {
      mileStone = await HttpService.leadMileStone(token, callMasterId);
      setState(() {});
    }
  }

  Future<void> listAddonDet(String token, String callMasterId) async {
    if (leadDetailsAdditional == null) {
      leadDetailsAdditional =
          await HttpService.listAddonDet(token, callMasterId);
      setState(() {});
    }
  }

  Future<void> _loadLeadDetails(String callMasterId) async {
    if (leadDetails == null || this.callMasterId != callMasterId) {
      leadDetails = await HttpService.leadDetails(widget.token, callMasterId);
      if (leadDetails != null) {
        this.callMasterId = callMasterId;
        contactMobile.text =
            await Common.addPlus(leadDetails!.data!.contactNumber1.toString());
        setState(() {
          whatsappNo1 = leadDetails!.data!.contactNumber1.toString();
          whatsappNo = leadDetails!.data!.contactNumber1.toString();
          contactFName.text = leadDetails!.data!.clientName.toString();
          contactMobile.text = '+${leadDetails!.data!.contactNumber1}';
        });
        listAddonDet(widget.token!, callMasterId);
        listFolderList(widget.token!, callMasterId, '');
        listMileStone(widget.token!, callMasterId);
      }
    }
  }

  void _toggleSortOrder() {
    setState(() {
      sortAscending = !sortAscending;
      currentSortOrder = sortAscending ? 'asc' : 'desc';
    });
    _clearCacheIfNeeded();
    getData(currentSortOrder, true, status);
  }

  void _clearCacheIfNeeded() {
    final newCacheKey = _generateCacheKey();
    if (_currentCacheKey != newCacheKey) {
      items.clear();
      page = 1;
      _currentCacheKey = newCacheKey;
    }
  }

  // Future<void> getData(String sort, bool isFirst, dynamic status1) async {
  //   String currentHash = _generateApiCallHash();
  //   if (_lastApiCallHash == currentHash && _isDataLoaded) {
  //     return;
  //   }
  //   _lastApiCallHash = currentHash;
  //   transferPermission = await Common.getSharedPref("transferLeads");
  //   userId = await Common.getSharedPref("userId");
  //   name = await Common.getSharedPref("name");
  //   setState(() {
  //     timeOut = false;
  //   });

  //   final String cacheKey = _generateCacheKey();
  //   _currentCacheKey = cacheKey;
  //   if (_leadCache.containsKey(cacheKey) && isFirst) {
  //     final cachedItems = _leadCache[cacheKey]!;
  //     final int startIndex = (page - 1) * pageSize;

  //     if (startIndex < cachedItems.length) {
  //       setState(() {
  //         items = cachedItems.sublist(0, startIndex + pageSize);
  //         isLoading = false;
  //         _isDataLoaded = true;
  //       });
  //       return;
  //     }
  //   }

  //   try {
  //     if (!isLoading) {
  //       setState(() {
  //         isLoading = true;
  //       });
  //       final connectivityResult = await (Connectivity().checkConnectivity());
  //       if (connectivityResult == ConnectivityResult.mobile ||
  //           connectivityResult == ConnectivityResult.wifi) {
  //         setState(() {
  //           result = true;
  //         });
  //       } else {
  //         setState(() {
  //           result = false;
  //         });
  //         return;
  //       }
  //       statusWise = await Common.getSharedPref("statusWise");
  //       roleId = await Common.getSharedPref("roleId");
  //       multiBranch = await Common.getSharedPref("multiBranch");
  //       if (statusWise == 'yes') {
  //         statusWiseId = await Common.getSharedPref("statusWisId");
  //         statusCatId = await Common.getSharedPref("statusCatId");
  //         type = await Common.getSharedPref("type");
  //         viewLeads = await HttpService.viewLeadsSts(
  //             widget.token,
  //             fromdate,
  //             todate,
  //             type,
  //             statusCatId,
  //             statusWiseId,
  //             sort,
  //             page,
  //             pageSize,
  //             isFirst,
  //             branch);
  //       } else {
  //         try {
  //           Map<String, dynamic> body = {
  //             "token": widget.token,
  //             // if (fromdate != null) "fromDate": outputFormat.format(fromdate!),
  //             // if (todate != null) "toDate": outputFormat.format(todate!),
  //             if (fromdate == null) "fromDate": "",
  //             if (todate == null) "toDate": "",
  //             "callResultId": status1 ?? "",
  //             "leadCategoryId": checkedCategoryItems,
  //             "callResponseId": checkedResponseItems,
  //             "staffId": checkedAssignedStaffItems,
  //             "isCalled": isCalled,
  //             "priority": checkedPriorityItems,
  //             "sort": sort,
  //             "page": page,
  //             "pageSize": pageSize,
  //             "isFirst": isFirst,
  //             "leadType": widget.leadType ?? "",
  //             "state": StateId ?? "",
  //             "district": DistrictId ?? "",
  //             "branchId": branch ?? ""
  //           };
  //           log(body.toString());
  //           viewLeads = await HttpService.viewLeads(body);
  //         } catch (e) {
  //           log(e.toString());
  //         }
  //       }
  //       if (commonDetails == null) {
  //         commonDetails = await HttpService.addLeadCommonData(widget.token);
  //         if (commonDetails != null) {
  //           filteredStaff.addAll(commonDetails!.data.transferStaffs);
  //         }
  //       }
  //       if (configure == null) {
  //         configure = await HttpService.configure(widget.token);
  //       }

  //       setState(() {
  //         if (isFirst) {
  //           items.clear();
  //         }
  //         // if (viewLeads != null) {
  //         //   items.addAll(viewLeads!.data.details);
  //         // }

  //         if (viewLeads != null) {
  //           final newItems = viewLeads!.data.details;

  //           // Update cache
  //           if (isFirst) {
  //             _leadCache[cacheKey] = List.from(newItems);
  //             _cacheTotalCounts[cacheKey] = viewLeads!.data.totalLeads;
  //             items.clear();
  //             items.addAll(newItems);
  //           } else {
  //             // Append to existing cache
  //             _leadCache[cacheKey]!.addAll(newItems);
  //             items.addAll(newItems);
  //           }

  //           setState(() {
  //             page++;
  //             isLoading = false;
  //             _isDataLoaded = true;
  //             isInitialLoad = false;
  //           });
  //         }
  //         // page++;
  //         // isLoading = false;
  //         // _isDataLoaded = true;
  //         // isInitialLoad = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       timeOut = true;
  //       _isDataLoaded = false;
  //     });
  //     log("error: $e");
  //   }

  //   phoneCallLogPermission =
  //       await Common.getSharedPref("phoneCallLogPermission");
  // }

  Future<void> getData(String sort, bool isFirst, dynamic status1) async {
    if (isLoading) return;
    setState(() {
      _isLoading = true;
    });
    String currentCacheKey = _generateCacheKey();
    _currentCacheKey = currentCacheKey;
    final currentPage = page;
    if (_leadCache.containsKey(currentCacheKey) &&
        _leadCache[currentCacheKey]!.containsKey(currentPage)) {
      final cachedPageItems = _leadCache[currentCacheKey]![currentPage]!;

      setState(() {
        if (isFirst) {
          items = List.from(cachedPageItems);
        } else {
          items.addAll(cachedPageItems);
        }
        //isLoading = false;
      });
      // return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        setState(() {
          result = true;
        });
      } else {
        setState(() {
          result = false;
          isLoading = false;
        });
        return;
      }

      statusWise = await Common.getSharedPref("statusWise");
      roleId = await Common.getSharedPref("roleId");
      multiBranch = await Common.getSharedPref("multiBranch");
      transferPermission = await Common.getSharedPref("transferLeads");
      userId = await Common.getSharedPref("userId");
      name = await Common.getSharedPref("name");
      if (statusWise == 'yes') {
        statusWiseId = await Common.getSharedPref("statusWisId");
        statusCatId = await Common.getSharedPref("statusCatId");
        type = await Common.getSharedPref("type");
        viewLeads = await HttpService.viewLeadsSts(
            widget.token,
            fromdate,
            todate,
            type,
            statusCatId,
            statusWiseId,
            sort,
            currentPage,
            pageSize,
            isFirst,
            branch);
      } else {
        Map<String, dynamic> body = {
          "token": widget.token,
          if (fromdate == null) "fromDate": "",
          if (todate == null) "toDate": "",
          "callResultId": status1 ?? "",
          "leadCategoryId": checkedCategoryItems,
          "callResponseId": checkedResponseItems,
          "staffId": checkedAssignedStaffItems,
          "isCalled": isCalled,
          "priority": checkedPriorityItems,
          "sort": sort,
          "page": currentPage,
          "pageSize": pageSize,
          "isFirst": isFirst,
          "leadType": widget.leadType ?? "",
          "state": StateId ?? "",
          "district": DistrictId ?? "",
          "branchId": branch ?? ""
        };
        log(body.toString());
        viewLeads = await HttpService.viewLeads(body);
      }

      if (commonDetails == null) {
        commonDetails = await HttpService.addLeadCommonData(widget.token);
        if (commonDetails != null) {
          filteredStaff.addAll(commonDetails!.data.transferStaffs);
        }
      }

      if (configure == null) {
        configure = await HttpService.configure(widget.token);
      }

      if (viewLeads != null) {
        final newItems = viewLeads!.data.details;
        if (!_leadCache.containsKey(currentCacheKey)) {
          _leadCache[currentCacheKey] = {};
          _cacheTotalCounts[currentCacheKey] = viewLeads!.data.totalLeads;
        }
        _leadCache[currentCacheKey]![currentPage] = List.from(newItems);

        setState(() {
          if (isFirst) {
            items.clear();
            items.addAll(newItems);
          } else {
            items.addAll(newItems);
          }
          page = currentPage + 1;
          isLoading = false;
          _isDataLoaded = true;
          isInitialLoad = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        timeOut = true;
        _isDataLoaded = false;
      });
      log("error: $e");
    }

    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      // onRefresh: () async {
      //   setState(() {
      //     _isDataLoaded = false;
      //     _lastApiCallHash = null;
      //   });
      //   items.clear();
      //   page = 1;
      //   await getData(currentSortOrder, true, status);
      // },
      onRefresh: () async {
        setState(() {
          _isDataLoaded = false;
        });
        final cacheKey = _generateCacheKey();
        if (_leadCache.containsKey(cacheKey)) {
          _leadCache.remove(cacheKey);
        }
        final currentItems = List<Detail>.from(items);
        page = 1;

        try {
          await getData(currentSortOrder, true, status);
        } catch (e) {
          setState(() {
            items = currentItems;
          });
          rethrow;
        }
      },
      child: result == true && timeOut == false
          ? Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: PreferredSize(
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
                child: Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 10.0, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.arrow_back_ios_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 25),
                            searchField == true
                                ? TextFormField(
                                    onChanged: (value) {},
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 10, top: 2, bottom: 2),
                                      labelText: 'Search',
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: Icon(Icons.person,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : Text(
                                    widget.pageName.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                          ],
                        ),
                        Row(
                          children: [
                            if (!searchField)
                              InkWell(
                                onTap: _toggleSortOrder,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
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
                            if (selectedIUsers.isNotEmpty)
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      selectedIUsers.length.toString(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 17),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  InkWell(
                                      onTap: () {
                                        if (transferPermission == "true") {
                                          transferLeads(context);
                                        } else {
                                          _dialogue(
                                              context, "transfer permission");
                                        }
                                      },
                                      child: const Icon(
                                        Icons.compare_arrows_rounded,
                                        color: Colors.white,
                                      )),
                                  const SizedBox(width: 15),
                                  InkWell(
                                      onTap: () {
                                        if (widget.deleteLead == true) {
                                          _showDeleteConfirmationDialog();
                                        } else {
                                          Common.toastMessaage(
                                              "You don't have permission to delete",
                                              Colors.red);
                                        }
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )),
                                ],
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              body: viewLeads != null && configure != null
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 10, top: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  // if (fromdate != null && todate != null)
                                  // Row(
                                  //   children: [
                                  //     const Text('Date from ',
                                  //         style: TextStyle(fontSize: 16)),
                                  //     const SizedBox(width: 5),
                                  //     Text(outputFormat.format(fromdate!),
                                  //         style: const TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.bold)),
                                  //     const SizedBox(width: 5),
                                  //     const Text(' to ',
                                  //         style: TextStyle(fontSize: 16)),
                                  //     const SizedBox(width: 5),
                                  //     Text(outputFormat.format(todate!),
                                  //         style: const TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.bold)),
                                  //     const SizedBox(width: 5),
                                  //   ],
                                  // ),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Total Leads : ${viewLeads!.data.totalLeads}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  filtrationSheet(context);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: const Color(0xFFd5f5f4),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Image.asset(
                                          "assets/icons/filter.png",
                                          width: 20)),
                                ),
                              )
                            ],
                          ),
                        ),
                        viewLeads!.data.details.isNotEmpty
                            ? Expanded(
                                child: ScrollablePositionedList.builder(
                                  initialScrollIndex: (widget.scrollToIndex !=
                                              null &&
                                          widget.scrollToIndex! < items.length)
                                      ? widget.scrollToIndex!
                                      : 0,
                                  itemCount: items.length + (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == items.length) {
                                      return _buildLoaderListItem();
                                    }
                                    return _buildLeadListItem(context, index);
                                  },
                                  itemScrollController: itemScrollController,
                                  itemPositionsListener: itemPositionsListener,
                                ),
                              )
                            : _buildEmptyState(),
                      ],
                    )
                  : _buildLoadingState(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(widget.token)),
                  );
                },
                child: Image.asset("assets/icons/menu.png", width: 25),
              ),
              bottomNavigationBar: configure != null
                  ? BottomNavigation(
                      widget.token!,
                      phoneCallLogPermission: phoneCallLogPermission,
                      name: name,
                      userId: userId,
                    )
                  : const SizedBox())
          : _buildErrorState(),
    );
  }

  Widget _buildLeadListItem(BuildContext context, int index) {
    if (index == items.length) {
      final cacheKey = _generateCacheKey();
      final totalLeads =
          _cacheTotalCounts[cacheKey] ?? viewLeads?.data.totalLeads ?? 0;

      if (items.length < totalLeads && isLoading) {
        return _buildLoaderListItem();
      } else if (items.length < totalLeads) {
        return Container(
          height: 60,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return Container();
      }
    }
    return Dismissible(
      key: Key(items[index].callMasterId.toString()),
      background: Container(
        color: Colors.green,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 20),
              Icon(Icons.call, color: Colors.white),
              Text(" Call",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.blue,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.add, color: Colors.white),
              Text("Add Followup",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return _handleFollowupAction(index);
        } else {
          return _handleCallAction(index);
        }
      },
      child: InkWell(
        onLongPress: () {
          _handleLongPress(index);
        },
        onTap: () {
          if (selectedIUsers.isNotEmpty) {
            _handleLongPress(index);
          } else {
            _navigateToLeadDetails(index);
          }
        },
        child: index < items.length
            ? leadListWidget(context, index)
            : const SizedBox(),
      ),
    );
  }

  Future<bool?> _handleFollowupAction(int index) {
    if (items[index].callResult != "Confirmed") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddFollowup(
                  widget.token,
                  widget.editLead,
                  widget.deleteLead,
                  widget.cloudCall,
                  items[index].callMasterId,
                  pageName: widget.pageName,
                  status: widget.status,
                  staff: widget.staff,
                  isCalled: widget.isCalled,
                  fromDate: widget.fromDate,
                  toDate: widget.toDate,
                  category: widget.category,
                  leadType: items[index].leadCategory,
                  leadTypeId: items[index].leadCategoryId,
                  leadSubType: items[index].leadSubCategory,
                  leadSubTypeId: items[index].leadSubCategoryId,
                  priorityId: items[index].priority,
                  priority: items[index].priorityName,
                  cost: items[index].cost,
                  address: items[index].address,
                  leadType1: widget.leadType,
                  preservedFromDate: fromdate,
                  preservedToDate: todate,
                  preservedSortOrder: currentSortOrder,
                  preservedSortAscending: sortAscending,
                  preservedCategoryItems:
                      List<String>.from(checkedCategoryItems),
                  preservedPriorityItems:
                      List<String>.from(checkedPriorityItems),
                  preservedAssignedStaffItems:
                      List<String>.from(checkedAssignedStaffItems),
                  preservedResponseItems:
                      List<String>.from(checkedResponseItems),
                )),
      ).then((value) {
        _handleReturnedData(value);
      });
    } else {
      Common.toastMessaage(
          "You can't follow up on confirmed leads", Colors.red);
    }
    return Future.value(false);
  }

  Future<bool?> _handleCallAction(int index) {
    if (viewLeads!.data.callPermission == false) {
      _showCallPermissionDialog(index);
    } else {
      if (widget.cloudCall == true) {
        chooseCallDialog(context, index);
      } else {
        Common.dialPad(items[index].contactNumber1);
      }
    }
    return Future.value(false);
  }

  void _handleLongPress(int index) {
    setState(() {
      items[index].isSelected = !items[index].isSelected;
      if (items[index].isSelected == true) {
        selectedIUsers.add(items[index].callMasterId);
        selectedUserNumbers.add(items[index].contactNumber1);
      } else {
        selectedIUsers.remove(items[index].callMasterId);
        selectedUserNumbers.remove(items[index].contactNumber1);
      }
    });
  }

  void _navigateToLeadDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MinimalLeadDetails(
                widget.token!,
                widget.editLead,
                widget.deleteLead,
                widget.cloudCall,
                items[index].callMasterId.toString(),
                pageName: widget.pageName.toString(),
                status: widget.status,
                staff: widget.staff,
                isCalled: widget.isCalled,
                fromDate: widget.fromDate,
                toDate: widget.toDate,
                category: widget.category,
                scrollToIndex: index,
                page: page,
                pageSize: page * pageSize,
                leadType: widget.leadType,
                preservedFromDate: fromdate,
                preservedToDate: todate,
                preservedSortOrder: currentSortOrder,
                preservedSortAscending: sortAscending,
                preservedCategoryItems: List<String>.from(checkedCategoryItems),
                preservedPriorityItems: List<String>.from(checkedPriorityItems),
                preservedAssignedStaffItems:
                    List<String>.from(checkedAssignedStaffItems),
                preservedResponseItems: List<String>.from(checkedResponseItems),
              )),
    ).then((returnedData) {
      _handleReturnedData(returnedData);
    });
  }

  // void _handleReturnedData(dynamic returnedData) {
  //   if (returnedData != null && returnedData is Map) {
  //     setState(() {
  //       fromdate = returnedData['preservedFromDate'];
  //       todate = returnedData['preservedToDate'];
  //       currentSortOrder =
  //           returnedData['preservedSortOrder'] ?? currentSortOrder;
  //       sortAscending = returnedData['preservedSortAscending'] ?? sortAscending;
  //       checkedCategoryItems = List<String>.from(
  //           returnedData['preservedCategoryItems'] ?? checkedCategoryItems);
  //       checkedPriorityItems = List<String>.from(
  //           returnedData['preservedPriorityItems'] ?? checkedPriorityItems);
  //       checkedAssignedStaffItems = List<String>.from(
  //           returnedData['preservedAssignedStaffItems'] ??
  //               checkedAssignedStaffItems);
  //       checkedResponseItems = List<String>.from(
  //           returnedData['preservedResponseItems'] ?? checkedResponseItems);
  //     });
  //   }

  //   final newCacheKey = _generateCacheKey();
  //   if (_currentCacheKey != newCacheKey) {
  //     setState(() {
  //       _isDataLoaded = false;
  //     });
  //     items.clear();
  //     page = 1;
  //     getData(currentSortOrder, true, status);
  //   }
  // }
  void _handleReturnedData(dynamic returnedData) {
    if (returnedData != null && returnedData is Map) {
      setState(() {
        fromdate = returnedData['preservedFromDate'];
        todate = returnedData['preservedToDate'];
        currentSortOrder =
            returnedData['preservedSortOrder'] ?? currentSortOrder;
        sortAscending = returnedData['preservedSortAscending'] ?? sortAscending;
        checkedCategoryItems = List<String>.from(
            returnedData['preservedCategoryItems'] ?? checkedCategoryItems);
        checkedPriorityItems = List<String>.from(
            returnedData['preservedPriorityItems'] ?? checkedPriorityItems);
        checkedAssignedStaffItems = List<String>.from(
            returnedData['preservedAssignedStaffItems'] ??
                checkedAssignedStaffItems);
        checkedResponseItems = List<String>.from(
            returnedData['preservedResponseItems'] ?? checkedResponseItems);
      });
    }

    final String? updatedLeadId = returnedData?['updatedLeadId'];
    if (updatedLeadId != null) {
      _removeLeadFromAllCaches(updatedLeadId);
      items.removeWhere((detail) => detail.callMasterId == updatedLeadId);
      if (widget.pageName == "Followup Leads") {
        setState(() {});
      } else {
        _refreshSingleLead(updatedLeadId);
      }
    } else {
      _smartCacheInvalidation();
    }

    final newCacheKey = _generateCacheKey();
    if (_currentCacheKey != newCacheKey) {
      items.clear();
      page = 1;
      getData(currentSortOrder, true, status);
    } else {
      setState(() {});
    }
  }

  void _removeLeadFromAllCaches(String leadId) {
    for (final cacheEntry in _leadCache.entries) {
      final cacheKey = cacheEntry.key;
      final pageMap = cacheEntry.value;

      for (final pageEntry in pageMap.entries) {
        final pageNum = pageEntry.key;
        final details = pageEntry.value;
        final newDetails =
            details.where((d) => d.callMasterId != leadId).toList();

        if (newDetails.length != details.length) {
          _leadCache[cacheKey]![pageNum] = newDetails;
          if (_cacheTotalCounts.containsKey(cacheKey)) {
            _cacheTotalCounts[cacheKey] = _cacheTotalCounts[cacheKey]! - 1;
          }
        }
      }
    }
  }

  void _refreshSingleLead(String leadId) {
    final cacheKey = _generateCacheKey();
    if (_leadCache.containsKey(cacheKey)) {}
  }

  void _smartCacheInvalidation() {
    final cacheKey = _generateCacheKey();
    if (_leadCache.containsKey(cacheKey)) {
      final cachedPages = _leadCache[cacheKey]!;
      final pagesToKeep =
          cachedPages.keys.where((pageNum) => pageNum <= 2).toList();
      final pagesToRemove =
          cachedPages.keys.where((pageNum) => pageNum > 2).toList();

      for (final pageNum in pagesToRemove) {
        cachedPages.remove(pageNum);
      }
    }

    setState(() {
      _isDataLoaded = false;
    });

    if (items.isNotEmpty) {
      final currentItems = List<Detail>.from(items);
      items.clear();
      page = 1;

      getData(currentSortOrder, true, status).then((_) {
        if (items.length < currentItems.length ~/ 2) {
        } else {}
      });
    }
  }

  void _showCallPermissionDialog(int index) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Alert !!!'),
            content: Text(viewLeads!.data.warningMessage.toString()),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close')),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeadDetails(
                              widget.token!,
                              widget.editLead,
                              widget.deleteLead,
                              widget.cloudCall,
                              viewLeads!.data.callLeadId.toString(),
                              pageName: widget.pageName.toString(),
                              status: widget.status,
                              staff: widget.staff,
                              isCalled: widget.isCalled,
                              fromDate: widget.fromDate,
                              toDate: widget.toDate,
                              category: widget.category,
                              scrollToIndex: index,
                              page: page,
                              pageSize: page * pageSize,
                              leadType: widget.leadType)),
                    ).then((r) {
                      items.clear();
                      page = 1;
                      getData('desc', true, status);
                    });
                  },
                  child: const Text('followup')),
            ],
          );
        });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset("assets/icons/nodatafound.png"),
          ),
          const Text('Result Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'Whoops... this information is \n not available for a moment',
              style: TextStyle(fontSize: 15)),
          const SizedBox(height: 25),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Dashboard(widget.token)));
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Go Back',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/noNetwork.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              textAlign: TextAlign.center,
              timeOut == true
                  ? "There seems to be a temporary issue !, \n Please retry to continue"
                  : 'No Network Found !',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                setState(() {
                  _isDataLoaded = false;
                  _lastApiCallHash = null;
                });
                page = 1;
                items.clear();
                getData('desc', true, status);
              },
              child: SizedBox(
                width: 120,
                height: 35,
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete Selected Leads?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    Map<String, dynamic> body = {
                      "token": widget.token,
                      'leadMasterIds': selectedIUsers,
                    };
                    BulkDeleteLeadModel deleteBulk =
                        await HttpService.bulkDeleteLead(body);
                    if (deleteBulk.data == true) {
                      Common.toastMessaage(deleteBulk.message, Colors.green);
                      selectedIUsers.clear();
                      if (context.mounted) {
                        Navigator.pop(context);
                        setState(() {
                          _isDataLoaded = false;
                          _lastApiCallHash = null;
                        });
                        page = 1;
                        items.clear();
                        getData('desc', false, status);
                      }
                    } else {
                      Common.toastMessaage(deleteBulk.message, Colors.red);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  Future<dynamic> transferLeads(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Transfer'),
              content: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.43,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade900, width: 0),
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: GestureDetector(
                      onTap: () {
                        collectedStaffDialog(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.38,
                                  child: Text(
                                    staffName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              )
                            ],
                          ),
                        )),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No')),
                TextButton(
                  onPressed: () async {
                    Common.showProgressDialog(context, "Loading..");
                    Map<String, dynamic> body = {
                      "token": widget.token,
                      'leadMasterIds': selectedIUsers,
                      'staffId': staffId
                    };
                    BulkTransferLeadModel bulkTransfer =
                        await HttpService.bulkTransferLead(body);

                    if (bulkTransfer.data == true) {
                      Common.toastMessaage(bulkTransfer.message, Colors.green);

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        setState(() {
                          selectedIUsers.clear();
                          selectedUserNumbers.clear();
                          for (var item in items) {
                            item.isSelected = false;
                          }
                        });
                        int currentPage = page;
                        items.clear();
                        page = 1;
                        getData('desc', false, status);

                        if (itemScrollController.isAttached) {
                          itemScrollController.scrollTo(
                            index: (currentPage - 1) * pageSize,
                            duration: const Duration(milliseconds: 500),
                          );
                        }
                      }
                    } else {
                      Common.toastMessaage(bulkTransfer.message, Colors.red);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          });
        });
  }

  Future<dynamic> collectedStaffDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        filteredStaff = commonDetails!.data.transferStaffs
                            .where((item) => item.tranStaffName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    itemCount: filteredStaff.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            staffName = filteredStaff[index].tranStaffName;
                            staffId = filteredStaff[index].tranStaffId;
                            filteredStaff.clear();
                            filteredStaff
                                .addAll(commonDetails!.data.transferStaffs);
                            setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(filteredStaff[index].tranStaffName));
                    },
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    filteredStaff.clear();
                    filteredStaff.addAll(commonDetails!.data.transferStaffs);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Close")),
            ],
          );
        });
      },
    );
  }

  Padding leadListWidget(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        decoration: BoxDecoration(
          color: items[index].isSelected == false
              ? Colors.white
              : Colors.blue.shade100,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(2.0, 2.0),
            )
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .88,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              if (items[index].priority == '1')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (items[index].priority == '2')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (items[index].priority == '3')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (items[index].priority == '4')
                                Container(
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .46,
                                child: Text(
                                  items[index].clientName == "null"
                                      ? "Unknown"
                                      : items[index].clientName.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      decoration: items[index].priority == "4"
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationThickness: 1.5,
                                      decorationColor: Colors.red,
                                      color: items[index].isCustomer
                                          ? Colors.green
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.pink.shade100,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 2),
                                    child: Text(
                                      items[index].leadCategory.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: items[index]
                                            .categoryCount
                                            .toString() !=
                                        "1" &&
                                    items[index].categoryCount.toString() != "",
                                child: GestureDetector(
                                  onTap: () async {
                                    Common.showProgressDialog(
                                        context, "Loading categories...");

                                    try {
                                      await _loadLeadDetails(
                                          items[index].callMasterId.toString());
                                      if (context.mounted)
                                        Navigator.pop(context);
                                      if (leadDetails == null ||
                                          leadDetails!.data?.leadCategories ==
                                              null) {
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("No Data"),
                                                content: const Text(
                                                    "Lead categories are not available yet."),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("OK"),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        return;
                                      }
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            final categories = leadDetails!
                                                .data!.leadCategories!;
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              insetPadding:
                                                  const EdgeInsets.all(20),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.75,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.9,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Header
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          "Lead Categories",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .blueAccent,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.grey),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                        ),
                                                      ],
                                                    ),
                                                    const Divider(
                                                        thickness: 1,
                                                        height: 16),
                                                    Expanded(
                                                      child: ListView.separated(
                                                        itemCount:
                                                            categories.length,
                                                        separatorBuilder:
                                                            (context, _) =>
                                                                const Divider(
                                                                    color: Colors
                                                                        .grey,
                                                                    height: 12),
                                                        itemBuilder:
                                                            (context, i) {
                                                          final category =
                                                              categories[i];
                                                          return Card(
                                                            elevation: 1,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: InkWell(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                                callMasterId = category
                                                                    .callMasterId
                                                                    .toString();
                                                                getData(
                                                                    'desc',
                                                                    true,
                                                                    status);
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        12),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        category.isSelected ==
                                                                                true
                                                                            ? const Icon(Icons.check_circle,
                                                                                size: 20,
                                                                                color: Colors.green)
                                                                            : const Icon(Icons.circle_outlined, size: 20, color: Colors.grey),
                                                                        const SizedBox(
                                                                            width:
                                                                                8),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            category.leadCategory ??
                                                                                "-",
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 4),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: (category.leadStatus ?? "") == "New"
                                                                                ? Colors.blue
                                                                                : (category.leadStatus ?? "") == "Follow Up"
                                                                                    ? Colors.orange
                                                                                    : (category.leadStatus ?? "") == "Rejected"
                                                                                        ? Colors.red
                                                                                        : Colors.purple,
                                                                            borderRadius:
                                                                                BorderRadius.circular(6),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            category.leadStatus ??
                                                                                "-",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            "👤 ${category.staffName ?? "-"}",
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black54,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            "📅 ${category.createdDate ?? "-"}",
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.black54,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                            Icons.close,
                                                            size: 18),
                                                        label:
                                                            const Text("Close"),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blueAccent,
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    } catch (error) {
                                      if (context.mounted)
                                        Navigator.pop(context);
                                      if (context.mounted) {
                                        Common.toastMessaage(
                                            "Failed to load categories",
                                            Colors.red);
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        items[index].categoryCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.68,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[index].contactNumber1.toString(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          'Assigned to : ${items[index].staffName}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: items[index].callResultId >=
                                                        0 &&
                                                    items[index].callResultId <
                                                        _colors.length
                                                ? _colors[
                                                    items[index].callResultId]
                                                : const Color.fromARGB(
                                                    255, 245, 160, 34),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5,
                                              right: 5,
                                              top: 2,
                                              bottom: 2),
                                          child: Text(
                                            items[index].callResult.toString(),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  items[index].callResultId == 1
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFd5f5f4),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                                top: 5,
                                                bottom: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                    "assets/icons/calendar.png",
                                                    width: 20),
                                                const SizedBox(width: 15),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Created Time',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      items[index]
                                                          .createdDate
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFd5f5f4),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5,
                                                    right: 5,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        "assets/icons/calendar.png",
                                                        width: 20),
                                                    const SizedBox(width: 5),
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          'Called Date',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        const SizedBox(
                                                            height: 3),
                                                        Text(
                                                          items[index].isCalled ==
                                                                  false
                                                              ? '--'
                                                              : items[index]
                                                                  .calledDate
                                                                  .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFd5f5f4),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5,
                                                    right: 5,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        "assets/icons/calendar.png",
                                                        width: 20),
                                                    const SizedBox(width: 5),
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          'Followup Date',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        const SizedBox(
                                                            height: 3),
                                                        Text(
                                                          items[index]
                                                              .scheduledDate
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 60),
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 20,
                                minWidth: 20,
                                maxHeight: 50,
                                maxWidth: 50,
                              ),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 0),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      offset: Offset(1, 1)),
                                ],
                                color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        items[index].profilePic.toString())),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              if (viewLeads!.data.callPermission == false) {
                                _showCallPermissionDialog(index);
                              } else {
                                if (widget.cloudCall == true) {
                                  chooseCallDialog(context, index);
                                } else {
                                  Common.dialPad(items[index].contactNumber1);
                                }
                              }
                            },
                            child: Container(
                              width: 65,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.call,
                                        color: Colors.white, size: 15),
                                    SizedBox(width: 5),
                                    Text('Call',
                                        style: TextStyle(
                                            fontFamily: "MontserratMedium",
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> filtrationSheet(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: IntrinsicHeight(
                child: Container(
                  width: double.maxFinite,
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Filtration',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('From Date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: DateTimePicker(
                                      decoration: InputDecoration(
                                          filled: true,
                                          //<-- SEE HERE
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.arrow_right,
                                            color: Colors.grey,
                                          ),
                                          counterText: "",
                                          hintText: 'From Date',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.purple.shade100),
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      initialValue: fromdate.toString(),
                                      type: DateTimePickerType.date,
                                      firstDate: DateTime(1995),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                      validator: (value) {
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            fromdate = DateTime.parse(value);
                                          });
                                        }
                                      },
                                      onSaved: (value) {
                                        if (value!.isNotEmpty) {
                                          fromdate = DateTime.parse(value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('To Date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: DateTimePicker(
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.arrow_right,
                                            color: Colors.grey,
                                          ),
                                          counterText: "",
                                          hintText: 'To Date',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.purple.shade100),
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      initialValue: todate.toString(),
                                      type: DateTimePickerType.date,
                                      firstDate: DateTime(1995),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                      validator: (value) {
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            todate = DateTime.parse(value);
                                          });
                                        }
                                      },
                                      onSaved: (value) {
                                        if (value!.isNotEmpty) {
                                          todate = DateTime.parse(value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (multiBranch == 'true' && roleId == '2')
                          _buildBranchFilter(setState),
                        if (widget.pageName == "Total Called" ||
                            widget.pageName == "Missed Leads")
                          _buildStatusFilter(setState),
                        _buildCategoryFilter(setState),
                        _buildPriorityFilter(setState),
                        _buildStateDistrictFilter(setState),
                        _buildAssignedStaffFilter(setState),
                        if (widget.pageName == "Total Called")
                          _buildCallResponseFilter(setState),
                        const SizedBox(height: 25),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () {
                              setState(() {
                                _isDataLoaded = false;
                                _lastApiCallHash = null;
                              });
                              items.clear();
                              page = 1;
                              pageSize = 20;
                              getData('desc', true, status);
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: const Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget _buildBranchFilter(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Branch',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: FormField<String>(
              builder: (FormFieldState<String> state) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade900, width: 1),
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('Branch')),
                      value: branch,
                      items: commonDetails?.data.branch.map((data) {
                        return DropdownMenuItem(
                          value: data.branchId.toString(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(data.branchName.toString()),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue1) async {
                        setState(() {
                          branch = newValue1;
                        });
                        commonDetails = await HttpService.addLeadCommonData(
                            widget.token,
                            branchId: branch);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(StateSetter setState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade900, width: 0),
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('Status')),
                      value: status,
                      items: commonDetails?.data.callResult.map((data) {
                        return DropdownMenuItem(
                          value: data.callResultId.toString(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(data.callResult.toString()),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          status = newValue;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(StateSetter setState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        const Text('Lead Category'),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Text('Lead Category'),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height * .32,
                      width: MediaQuery.of(context).size.height * .8,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: commonDetails?.data.leadCategory.length ?? 0,
                        itemBuilder: (context, ind) {
                          return CheckboxListTile(
                            title: SizedBox(
                              width: 200,
                              child: Text(
                                commonDetails!
                                    .data.leadCategory[ind].leadCategory
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                            ),
                            value: checkedCategoryItems.contains(commonDetails!
                                .data.leadCategory[ind].leadCategoryId
                                .toString()),
                            onChanged: (bool? value) {
                              if (value == true) {
                                setState(() {
                                  checkedCategoryItems.add(commonDetails!
                                      .data.leadCategory[ind].leadCategoryId
                                      .toString());
                                  checkedCategoryItemsName.add(commonDetails!
                                      .data.leadCategory[ind].leadCategory
                                      .toString());
                                  Navigator.pop(context, true);
                                });
                              } else {
                                setState(() {
                                  checkedCategoryItems.remove(commonDetails!
                                      .data.leadCategory[ind].leadCategoryId
                                      .toString());
                                  checkedCategoryItemsName.remove(commonDetails!
                                      .data.leadCategory[ind].leadCategory
                                      .toString());
                                  Navigator.pop(context, true);
                                });
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  );
                });
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(5),
            ),
            child: checkedCategoryItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 10, top: 15, bottom: 10),
                    child: Text('Lead Category'))
                : Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: checkedCategoryItemsName.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: InkWell(
                              onTap: () {
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 0),
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomLeft: Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              checkedCategoryItemsName[i],
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Please Confirm'),
                                              content: const Text(
                                                  'Are you sure to Remove this Number?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('No')),
                                                TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        checkedCategoryItemsName
                                                            .remove(
                                                                checkedCategoryItemsName[
                                                                    i]);
                                                        checkedCategoryItems.remove(
                                                            checkedCategoryItems[
                                                                i]);
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Yes')),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0),
                                          color: Colors.grey.shade100,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(6),
                                              bottomRight: Radius.circular(6))),
                                      child: const Icon(Icons.close,
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityFilter(StateSetter setState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        const Text('Priority'),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Text('Priority'),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height * .23,
                      width: MediaQuery.of(context).size.height * .8,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: commonDetails?.data.priority.length ?? 0,
                        itemBuilder: (context, ind) {
                          return CheckboxListTile(
                            title: SizedBox(
                              width: 200,
                              child: Text(
                                commonDetails!.data.priority[ind].priority
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                            ),
                            value: checkedPriorityItems.contains(commonDetails!
                                .data.priority[ind].priorityId
                                .toString()),
                            onChanged: (bool? value) {
                              if (value == true) {
                                setState(() {
                                  checkedPriorityItems.add(commonDetails!
                                      .data.priority[ind].priorityId
                                      .toString());
                                  checkedPriorityItemsName.add(commonDetails!
                                      .data.priority[ind].priority
                                      .toString());
                                  Navigator.pop(context, true);
                                });
                              } else {
                                setState(() {
                                  checkedPriorityItems.remove(commonDetails!
                                      .data.priority[ind].priorityId
                                      .toString());
                                  checkedPriorityItemsName.remove(commonDetails!
                                      .data.priority[ind].priority
                                      .toString());
                                  Navigator.pop(context, true);
                                });
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  );
                });
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(5),
            ),
            child: checkedPriorityItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 10, top: 15, bottom: 10),
                    child: Text('Priority'))
                : Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: checkedPriorityItemsName.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: InkWell(
                              onTap: () {
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 0),
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomLeft: Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              checkedPriorityItemsName[i],
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Please Confirm'),
                                              content: const Text(
                                                  'Are you sure to Remove this Number?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('No')),
                                                TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        checkedPriorityItemsName
                                                            .remove(
                                                                checkedPriorityItemsName[
                                                                    i]);
                                                        checkedPriorityItems.remove(
                                                            checkedPriorityItems[
                                                                i]);
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Yes')),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0),
                                          color: Colors.grey.shade100,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(6),
                                              bottomRight: Radius.circular(6))),
                                      child: const Icon(Icons.close,
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateDistrictFilter(StateSetter setState) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          width: 337,
          child: TextFormField(
            controller: stateVal,
            readOnly: true,
            onTap: () async {
              final selectedState = await selectStateDialog(context);
              if (selectedState != null) {
                setState(() {
                  stateVal.text = selectedState.name;
                  StateId = selectedState.id;
                  districtVal.clear();
                  districtList = [];
                  isDistrictLoading = true;
                });

                final result = await HttpService.getDistrict(StateId!);
                setState(() {
                  districtList = result?.data ?? [];
                  isDistrictLoading = false;
                  if (districtList.isNotEmpty) {
                    DistrictId = districtList.first.id;
                    districtVal.text = districtList.first.name;
                  }
                });
              }
            },
            decoration: const InputDecoration(
              labelText: 'State',
              prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined,
                  color: Colors.grey),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (!isDistrictLoading && districtList.isNotEmpty)
          SizedBox(
            width: 337,
            child: DropdownButtonFormField<DistrictList>(
              value: districtList.firstWhere((d) => d.id == DistrictId,
                  orElse: () => districtList.first),
              decoration: const InputDecoration(
                  labelText: 'Select District', border: OutlineInputBorder()),
              items: districtList.map((d) {
                return DropdownMenuItem<DistrictList>(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  DistrictId = value?.id;
                  districtVal.text = value?.name ?? '';
                });
              },
            ),
          ),
        if (isDistrictLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildAssignedStaffFilter(StateSetter setState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        const Text('Assigned Staff'),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Text('Assign Staff'),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height * .32,
                      width: MediaQuery.of(context).size.height * .8,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: commonDetails?.data.staff.length ?? 0,
                        itemBuilder: (context, ind) {
                          return CheckboxListTile(
                            title: SizedBox(
                              width: 200,
                              child: Text(
                                commonDetails!.data.staff[ind].staffName
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                            ),
                            value: checkedAssignedStaffItems.contains(
                                commonDetails!.data.staff[ind].userId
                                    .toString()),
                            onChanged: (bool? value) {
                              if (value == true) {
                                setState(() {
                                  checkedAssignedStaffItems.add(commonDetails!
                                      .data.staff[ind].userId
                                      .toString());
                                  checkedAssignedStaffItemsName.add(
                                      commonDetails!.data.staff[ind].staffName
                                          .toString());
                                  Navigator.pop(context, true);
                                });
                              } else {
                                setState(() {
                                  checkedAssignedStaffItems.remove(
                                      commonDetails!.data.staff[ind].userId
                                          .toString());
                                  checkedAssignedStaffItemsName.remove(
                                      commonDetails!.data.staff[ind].staffName
                                          .toString());
                                  Navigator.pop(context, true);
                                });
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  );
                });
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(5),
            ),
            child: checkedAssignedStaffItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 10, top: 15, bottom: 10),
                    child: Text('Assigned Staff'))
                : Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: checkedAssignedStaffItemsName.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: InkWell(
                              onTap: () {
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 0),
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomLeft: Radius.circular(6))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              checkedAssignedStaffItemsName[i],
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Please Confirm'),
                                              content: const Text(
                                                  'Are you sure to Remove this Number?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('No')),
                                                TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        checkedAssignedStaffItemsName
                                                            .remove(
                                                                checkedAssignedStaffItemsName[
                                                                    i]);
                                                        checkedAssignedStaffItems
                                                            .remove(
                                                                checkedAssignedStaffItems[
                                                                    i]);
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Yes')),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0),
                                          color: Colors.grey.shade100,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(6),
                                              bottomRight: Radius.circular(6))),
                                      child: const Icon(Icons.close,
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallResponseFilter(StateSetter setState) {
    return Visibility(
      visible: widget.pageName == "Total Called",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 13),
          const Text('Call Response',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Call Response'),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height * .32,
                        width: MediaQuery.of(context).size.width * .8,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              commonDetails?.data.callResponseStatus.length ??
                                  0,
                          itemBuilder: (context, ind) {
                            return CheckboxListTile(
                              title: SizedBox(
                                width: 200,
                                child: Text(
                                  commonDetails!
                                      .data.callResponseStatus[ind].callResponse
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                              ),
                              value: checkedResponseItems.contains(
                                  commonDetails!.data.callResponseStatus[ind]
                                      .callResponseId
                                      .toString()),
                              onChanged: (bool? value) {
                                if (value == true) {
                                  setState(() {
                                    checkedResponseItems.add(commonDetails!.data
                                        .callResponseStatus[ind].callResponseId
                                        .toString());
                                    checkedresponseItemsName.add(commonDetails!
                                        .data
                                        .callResponseStatus[ind]
                                        .callResponse
                                        .toString());
                                    Navigator.pop(context, true);
                                  });
                                } else {
                                  setState(() {
                                    checkedResponseItems.remove(commonDetails!
                                        .data
                                        .callResponseStatus[ind]
                                        .callResponseId
                                        .toString());
                                    checkedresponseItemsName.remove(
                                        commonDetails!
                                            .data
                                            .callResponseStatus[ind]
                                            .callResponse
                                            .toString());
                                    Navigator.pop(context, true);
                                  });
                                }
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                    );
                  });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5),
              ),
              child: checkedResponseItems.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 10),
                      child: Text('Call Response'))
                  : Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: SizedBox(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: checkedresponseItemsName.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: InkWell(
                                onTap: () {
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0),
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              bottomLeft: Radius.circular(6))),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                checkedresponseItemsName[i],
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Please Confirm'),
                                                content: const Text(
                                                    'Are you sure to Remove this Number?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text('No')),
                                                  TextButton(
                                                      onPressed: () async {
                                                        setState(() {
                                                          checkedresponseItemsName
                                                              .remove(
                                                                  checkedresponseItemsName[
                                                                      i]);
                                                          checkedResponseItems
                                                              .remove(
                                                                  checkedResponseItems[
                                                                      i]);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('Yes')),
                                                ],
                                              );
                                            });
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0),
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(6),
                                                    bottomRight:
                                                        Radius.circular(6))),
                                        child: const Icon(Icons.close,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Choose Call Type'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    Common.showProgressDialog(context, "Loading..");
                    CloudCallModel object1 = await HttpService.addCloudCall(
                        widget.token,
                        items[index].callMasterId.toString(),
                        items[index].contactNumber1);
                    if (object1.data == true) {
                      if (context.mounted) {
                        Common.toastMessaage(object1.message, Colors.green);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } else {
                      Common.toastMessaage(object1.message, Colors.red);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Icon(Icons.cloud_circle_rounded,
                              color: Colors.black),
                        ),
                        const SizedBox(width: 20),
                        const Text('Cloud Call',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    Common.dialPad(items[index].contactNumber1);
                  },
                  child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5)),
                            child: const Icon(Icons.call, color: Colors.black),
                          ),
                          const SizedBox(width: 20),
                          const Text('Phone Call',
                              style: TextStyle(fontSize: 18)),
                        ],
                      )),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildLoaderListItem() {
    return Shimmer.fromColors(
        enabled: true,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white),
                    const SizedBox(height: 8.0),
                    Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              height: 10.0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8.0)),
                          Container(
                              width: double.infinity,
                              height: 10.0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8.0)),
                          Container(
                              width: 100.0, height: 10.0, color: Colors.white)
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white),
                    const SizedBox(height: 8.0),
                    Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 200,
                              height: 10.0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8.0)),
                          Container(
                              width: double.infinity,
                              height: 10.0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8.0)),
                          Container(
                              width: 100.0, height: 10.0, color: Colors.white)
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 200, height: 12.0, color: Colors.white),
                    const SizedBox(height: 8.0),
                    Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              height: 10.0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8.0)),
                          Container(
                              width: double.infinity,
                              height: 10.0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8.0)),
                          Container(
                              width: 100.0, height: 10.0, color: Colors.white)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void _dialogue(BuildContext context, title) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Alert !!!'),
            content: const Text(
                'You have no permission to access the feature please contact the support team'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'))
            ],
          );
        });
  }
}

class MessageViewWidget extends StatelessWidget {
  const MessageViewWidget({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Text(label));
  }
}
