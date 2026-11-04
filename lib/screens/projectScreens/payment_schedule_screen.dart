// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../models/projectdetails/staff_list_model.dart';
// import '../../models/projectdetails/unit_list_model.dart';
// import '../../models/projectdetails/payment_schedule/payment_schedule_model.dart';
// import '../../models/projectdetails/payment_schedule/stage_model.dart';
// import '../../service/service.dart';

// class PaymentScheduleScreen extends StatefulWidget {
//   final String projectId;
//   final String projectNo;

//   const PaymentScheduleScreen({
//     super.key,
//     required this.projectId,
//     required this.projectNo,
//   });

//   @override
//   State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
// }

// class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
//   static const Color _primary = Color(0xFF2A86C9);
//   static const Color _primaryDark = Color(0xFF1A6CA8);

//   // OFFLINE STATE
//   bool _isOffline = false;

//   // LIST STATE
//   bool _isLoading = true;
//   List<PaymentScheduleRecord> _schedules = [];
//   PaymentScheduleSummary _summary = PaymentScheduleSummary.empty();

//   @override
//   void initState() {
//     super.initState();
//     _loadPaymentSchedules();
//   }

//   // CHECK INTERNET
//   Future<bool> _hasInternet() async {
//     try {
//       final result = await InternetAddress.lookup('google.com')
//           .timeout(const Duration(seconds: 5));

//       return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   // LOAD / REFRESH PAYMENT SCHEDULES
//   Future<void> _loadPaymentSchedules() async {
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }

//     final online = await _hasInternet();

//     if (!mounted) return;

//     setState(() {
//       _isOffline = !online;
//     });

//     if (!online) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await HttpService.getPaymentSchedules(
//         projectId: widget.projectId,
//       );

//       if (!mounted) return;

//       if (response != null && response.status && response.data != null) {
//         setState(() {
//           _schedules = response.data!.records;
//           _summary = response.data!.summary;
//         });
//       } else {
//         setState(() {
//           _schedules = [];
//           _summary = PaymentScheduleSummary.empty();
//         });
//       }
//     } catch (e) {
//       log('Load payment schedules error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _openAddPaymentScheduleDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return _AddPaymentScheduleDialog(
//           projectId: widget.projectId,
//           projectNo: widget.projectNo,
//           onSuccess: () {
//             // Refresh the payment schedule list
//             _loadPaymentSchedules();
//           },
//         );
//       },
//     );
//   }

//   //empty
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: _primary.withOpacity(0.10),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.payment_outlined,
//                 size: 42,
//                 color: _primary,
//               ),
//             ),
//             const SizedBox(height: 18),
//             const Text(
//               'No payment schedules found',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'No project payment schedule records are available.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // NO INTERNET STATE
//   Widget _buildOfflineState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: _primary.withOpacity(0.10),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.wifi_off_rounded,
//                 size: 42,
//                 color: _primary,
//               ),
//             ),
//             const SizedBox(height: 18),
//             const Text(
//               'No Internet Connection',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Please check your connection and pull down to refresh.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _loadPaymentSchedules,
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _primary,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // CARD HELPERS

//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'paid':
//       case 'completed':
//         return Colors.green;
//       case 'partial':
//       case 'partially paid':
//         return Colors.blue;
//       case 'open':
//       case 'pending':
//         return Colors.orange;
//       case 'overdue':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _money(String value) {
//     final n = num.tryParse(value.trim()) ?? 0;
//     return '\u20B9 ${n.toStringAsFixed(2)}';
//   }

//   String _percent(String value) {
//     final n = double.tryParse(value.trim()) ?? 0;
//     if (n == n.truncateToDouble()) return '${n.toInt()}%';
//     return '${n.toStringAsFixed(1)}%';
//   }

//   Widget _buildDetailItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     Color iconColor = _primary,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: iconColor.withOpacity(0.10),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 17, color: iconColor),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value.isEmpty ? '-' : value,
//                 style: const TextStyle(
//                   fontSize: 13.5,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScheduleCard(PaymentScheduleRecord item) {
//     final statusColor = _statusColor(item.paymentStatus);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // HEADER: stage name + status chip
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: _primary.withOpacity(0.12),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.payments_rounded,
//                   size: 20,
//                   color: _primary,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Stage',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       item.stageNames.isEmpty ? '-' : item.stageNames,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               if (item.locked)
//                 const Padding(
//                   padding: EdgeInsets.only(right: 8),
//                   child: Icon(
//                     Icons.lock_outline_rounded,
//                     size: 18,
//                     color: Colors.grey,
//                   ),
//                 ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   item.paymentStatus.isEmpty ? '-' : item.paymentStatus,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: statusColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 12),
//             child: Divider(height: 1),
//           ),

//           // ROW 1: Unit + Site Lift
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailItem(
//                   icon: Icons.badge_rounded,
//                   label: 'Unit No',
//                   value: item.unitName,
//                   iconColor: Colors.purple,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildDetailItem(
//                   icon: Icons.label_rounded,
//                   label: 'Site Lift No',
//                   value: item.siteLiftName,
//                   iconColor: Colors.teal,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // ROW 2: Percentage + Amount
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailItem(
//                   icon: Icons.percent_rounded,
//                   label: 'Percentage',
//                   value: _percent(item.percentage),
//                   iconColor: Colors.indigo,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildDetailItem(
//                   icon: Icons.currency_rupee_rounded,
//                   label: 'Amount',
//                   value: _money(item.amount),
//                   iconColor: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // ROW 3: Paid + Balance
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailItem(
//                   icon: Icons.check_circle_outline_rounded,
//                   label: 'Paid',
//                   value: _money(item.paidAmount),
//                   iconColor: Colors.green,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildDetailItem(
//                   icon: Icons.account_balance_wallet_outlined,
//                   label: 'Balance',
//                   value: _money(item.balanceAmount),
//                   iconColor: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // ROW 4: Due date
//           _buildDetailItem(
//             icon: Icons.calendar_today_rounded,
//             label: 'Due Date',
//             value: item.dueDate,
//             iconColor: Colors.orange,
//           ),
//         ],
//       ),
//     );
//   }

//   // FIXED BOTTOM SUMMARY BAR
//   Widget _buildSummaryBar() {
//     Widget cell(String label, String value) {
//       return Expanded(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 3),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 _money(value),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14.5,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [_primary, _primaryDark],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           child: Row(
//             children: [
//               cell('Total', _summary.totalAmount),
//               cell('Paid', _summary.totalPaidAmount),
//               cell('Balance', _summary.totalBalance),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // BODY (pull-to-refresh enabled)
//   Widget _buildBody() {
//     if (_isLoading && _schedules.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(color: _primary),
//       );
//     }

//     // Offline or empty: scrollable so pull-to-refresh still works
//     if (_isOffline || _schedules.isEmpty) {
//       return RefreshIndicator(
//         color: _primary,
//         onRefresh: _loadPaymentSchedules,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight,
//                 ),
//                 child: _isOffline ? _buildOfflineState() : _buildEmptyState(),
//               ),
//             );
//           },
//         ),
//       );
//     }

//     return RefreshIndicator(
//       color: _primary,
//       onRefresh: _loadPaymentSchedules,
//       child: ListView.builder(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(20),
//         itemCount: _schedules.length,
//         itemBuilder: (context, index) {
//           return _buildScheduleCard(_schedules[index]);
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5FB),
//       appBar: AppBar(
//         title: const Text(
//           'Payment Schedule',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 17,
//           ),
//         ),
//         backgroundColor: _primary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: Colors.white,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.add,
//                 color: Colors.white,
//                 size: 28,
//               ),
//               onPressed: _openAddPaymentScheduleDialog,
//             ),
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 _primary,
//                 _primaryDark,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: _buildBody(),
//       bottomNavigationBar:
//           _schedules.isNotEmpty && !_isOffline ? _buildSummaryBar() : null,
//     );
//   }
// }

// // ADD PAYMENT SCHEDULE DIALOG

// class _AddPaymentScheduleDialog extends StatefulWidget {
//   final String projectId;
//   final String projectNo;
//   final VoidCallback onSuccess;

//   const _AddPaymentScheduleDialog({
//     required this.projectId,
//     required this.projectNo,
//     required this.onSuccess,
//   });

//   @override
//   State<_AddPaymentScheduleDialog> createState() =>
//       __AddPaymentScheduleDialogState();
// }

// class __AddPaymentScheduleDialogState extends State<_AddPaymentScheduleDialog> {
//   static const Color _primary = Color(0xFF2A86C9);

//   final _formKey = GlobalKey<FormState>();

//   ProjectDocumentUnit? _selectedUnit;
//   SiteLift? _selectedSiteLift;

//   List<FitStage> _selectedStages = [];

//   bool _isLoadingStages = false;
//   List<FitStage> _stageList = [];

//   bool _isLoadingUnits = false;
//   bool _isLoadingSiteLifts = false;
//   bool _isSubmitting = false;

//   List<ProjectDocumentUnit> _unitList = [];
//   List<SiteLift> _siteLiftList = [];

//   // Picked due date (kept as DateTime so it can be sent as yyyy-MM-dd)
//   DateTime? _dueDate;

//   // Controllers for separate fields
//   final TextEditingController _percentageController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _dueDateController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadUnits();
//     _loadSiteLifts();
//     _loadFitStages();
//   }

//   @override
//   void dispose() {
//     _percentageController.dispose();
//     _amountController.dispose();
//     _dueDateController.dispose();
//     super.dispose();
//   }

//   // LOAD UNITS API
//   Future<void> _loadUnits() async {
//     setState(() {
//       _isLoadingUnits = true;
//     });

//     try {
//       final response = await HttpService.getProjectDocumentUnits(
//         projectId: widget.projectId,
//       );

//       if (!mounted) return;

//       if (response != null && response.status) {
//         setState(() {
//           _unitList = response.data;
//         });
//       }
//     } catch (e) {
//       log('Unit API error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingUnits = false;
//         });
//       }
//     }
//   }

//   // LOAD SITE LIFTS API
//   Future<void> _loadSiteLifts() async {
//     setState(() {
//       _isLoadingSiteLifts = true;
//     });

//     try {
//       final response = await HttpService.getSiteLifts(
//         projectId: widget.projectId,
//       );

//       if (!mounted) return;

//       if (response != null && response.status) {
//         setState(() {
//           _siteLiftList = response.data;
//         });
//       }
//     } catch (e) {
//       log('Site Lift API error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingSiteLifts = false;
//         });
//       }
//     }
//   }

//   //LOAD FIT STAGES API
//   Future<void> _loadFitStages() async {
//     setState(() {
//       _isLoadingStages = true;
//     });

//     try {
//       final response = await HttpService.getFitStages(
//         projectId: widget.projectId,
//       );

//       if (!mounted) return;

//       if (response != null && response.status) {
//         setState(() {
//           _stageList = response.data;
//         });
//       }
//     } catch (e) {
//       log('Fit stages API error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingStages = false;
//         });
//       }
//     }
//   }

//   // MULTI-SELECT STAGE PICKER
//   Future<void> _openStagePicker() async {
//     final List<FitStage> temp = List<FitStage>.from(_selectedStages);

//     final result = await showDialog<List<FitStage>>(
//       context: context,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (ctx, setDialogState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               title: const Text(
//                 'Select Stages',
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 8),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: _stageList.map((stage) {
//                     final bool checked =
//                         temp.any((s) => s.activityKey == stage.activityKey);

//                     return CheckboxListTile(
//                       value: checked,
//                       dense: true,
//                       activeColor: _primary,
//                       controlAffinity: ListTileControlAffinity.leading,
//                       title: Text(
//                         stage.activityName,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       onChanged: (value) {
//                         setDialogState(() {
//                           if (value == true) {
//                             temp.add(stage);
//                           } else {
//                             temp.removeWhere(
//                                 (s) => s.activityKey == stage.activityKey);
//                           }
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(ctx, temp),
//                   style: ElevatedButton.styleFrom(
//                     elevation: 0,
//                     backgroundColor: _primary,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text('Done (${temp.length})'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (result != null && mounted) {
//       setState(() {
//         _selectedStages = result;
//       });
//     }
//   }

//   // MULTI-SELECT STAGE FIELD
//   Widget _buildStageMultiSelect() {
//     return FormField<List<FitStage>>(
//       validator: (_) =>
//           _selectedStages.isEmpty ? 'This field is required' : null,
//       builder: (state) {
//         return InkWell(
//           borderRadius: BorderRadius.circular(8),
//           onTap: _isLoadingStages
//               ? null
//               : () async {
//                   await _openStagePicker();
//                   state.didChange(_selectedStages);
//                 },
//           child: InputDecorator(
//             isEmpty: false,
//             decoration: _inputDecoration('').copyWith(
//               errorText: state.errorText,
//               suffixIcon: _isLoadingStages
//                   ? const Padding(
//                       padding: EdgeInsets.all(12),
//                       child: SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     )
//                   : const Icon(Icons.keyboard_arrow_down_rounded),
//             ),
//             child: _selectedStages.isEmpty
//                 ? Text(
//                     _isLoadingStages ? 'Loading...' : 'Select Stages',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                   )
//                 : Wrap(
//                     spacing: 6,
//                     runSpacing: 4,
//                     children: _selectedStages.map((stage) {
//                       return Chip(
//                         label: Text(
//                           stage.activityName,
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                         backgroundColor: _primary.withOpacity(0.10),
//                         side: BorderSide.none,
//                         visualDensity: VisualDensity.compact,
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         onDeleted: () {
//                           setState(() {
//                             _selectedStages.removeWhere(
//                                 (s) => s.activityKey == stage.activityKey);
//                           });
//                           state.didChange(_selectedStages);
//                         },
//                       );
//                     }).toList(),
//                   ),
//           ),
//         );
//       },
//     );
//   }

//   // DATE PICKER
//   Future<void> _pickDueDate() async {
//     final DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: _dueDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (date != null) {
//       setState(() {
//         _dueDate = date;
//         _dueDateController.text =
//             "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//       });
//     }
//   }

//   InputDecoration _inputDecoration(String hint, {Widget? prefixIcon}) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       prefixIcon: prefixIcon,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 12,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(
//           color: _primary,
//           width: 1.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String labelText, {bool required = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: RichText(
//         text: TextSpan(
//           text: labelText,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//           children: [
//             if (required)
//               const TextSpan(
//                 text: ' *',
//                 style: TextStyle(color: Colors.red),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown<T>({
//     required T? value,
//     required String hint,
//     required List<T> items,
//     required String Function(T) getLabel,
//     required ValueChanged<T?> onChanged,
//     bool isLoading = false,
//   }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       isExpanded: true,
//       decoration: _inputDecoration(isLoading ? 'Loading...' : hint),
//       icon: isLoading
//           ? const SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : const Icon(Icons.keyboard_arrow_down_rounded),
//       // Set menuMaxHeight to prevent overflow if the list is long
//       menuMaxHeight: 300,
//       items: items.map((item) {
//         return DropdownMenuItem<T>(
//           value: item,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return ConstrainedBox(
//                 constraints: BoxConstraints(minWidth: constraints.maxWidth),
//                 child: Text(
//                   getLabel(item),
//                   // Remove overflow truncation by letting it wrap or handle max lines
//                   style: const TextStyle(fontSize: 14),
//                   overflow: TextOverflow.visible,
//                   softWrap: true,
//                 ),
//               );
//             },
//           ),
//         );
//       }).toList(),
//       onChanged: isLoading ? null : onChanged,
//       validator: (val) => val == null ? 'This field is required' : null,
//     );
//   }

//   // SUBMIT FORM
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       final String unitId = _selectedUnit?.id ?? '';
//       final String siteLiftId = _selectedSiteLift?.id ?? '';
//       final List<String> stageIds =
//           _selectedStages.map((s) => s.activityKey).toList();
//       final String percentage = _percentageController.text.trim();
//       final String amount = _amountController.text.trim();

//       // API format: yyyy-MM-dd
//       final String dueDate = _dueDate == null
//           ? ''
//           : '${_dueDate!.year}-'
//               '${_dueDate!.month.toString().padLeft(2, '0')}-'
//               '${_dueDate!.day.toString().padLeft(2, '0')}';

//       print(
//           'Unit: $unitId, Lift: $siteLiftId, Stages: $stageIds, %: $percentage, Amt: $amount, Due: $dueDate');

//       final bool success = await HttpService.addPaymentSchedule(
//         projectId: widget.projectId,
//         unitNo: unitId,
//         siteLiftNo: siteLiftId,
//         stageIds: stageIds,
//         amount: amount,
//         percentage: percentage,
//         dueDate: dueDate,
//       );

//       if (!mounted) return;

//       if (success) {
//         Navigator.pop(context);
//         widget.onSuccess();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Payment schedule added successfully'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to add payment schedule'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       log('Add payment schedule error: $e');
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to add payment schedule: $e'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 0.85,
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // HEADER
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Payment Schedule',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () => Navigator.pop(context),
//                         child: const Icon(
//                           Icons.close,
//                           size: 20,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 1. UNIT NO DROPDOWN
//                   _buildLabel('Unit No.', required: true),
//                   _buildDropdown<ProjectDocumentUnit>(
//                     value: _selectedUnit,
//                     hint: 'Select a Unit',
//                     items: _unitList,
//                     getLabel: (unit) => unit.unitNo,
//                     onChanged: (value) => setState(() => _selectedUnit = value),
//                     isLoading: _isLoadingUnits,
//                   ),
//                   const SizedBox(height: 16),

//                   // 2. SITE LIFT NO DROPDOWN
//                   _buildLabel('Site Lift No.', required: true),
//                   _buildDropdown<SiteLift>(
//                     value: _selectedSiteLift,
//                     hint: 'Select Site Lift No.',
//                     items: _siteLiftList,
//                     getLabel: (lift) => lift.siteLiftName,
//                     onChanged: (value) =>
//                         setState(() => _selectedSiteLift = value),
//                     isLoading: _isLoadingSiteLifts,
//                   ),
//                   const SizedBox(height: 16),

//                   // 3. SELECT STAGES
//                   _buildLabel('Select Stages', required: true),
//                   _buildStageMultiSelect(),
//                   const SizedBox(height: 16),

//                   // 4. PERCENTAGE + AMOUNT (side by side)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildLabel('Percentage'),
//                             TextFormField(
//                               controller: _percentageController,
//                               keyboardType: TextInputType.number,
//                               decoration: _inputDecoration(
//                                 'Percent',
//                                 prefixIcon: const Icon(
//                                   Icons.percent,
//                                   size: 16,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildLabel('Amount', required: true),
//                             TextFormField(
//                               controller: _amountController,
//                               keyboardType: TextInputType.number,
//                               decoration: _inputDecoration(
//                                 'Amount',
//                                 prefixIcon: const Icon(
//                                   Icons.currency_rupee,
//                                   size: 16,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               validator: (val) =>
//                                   val == null || val.trim().isEmpty
//                                       ? 'Required'
//                                       : null,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // 5. DUE DATE
//                   _buildLabel('Due Date'),
//                   TextFormField(
//                     controller: _dueDateController,
//                     readOnly: true,
//                     onTap: _pickDueDate,
//                     decoration: _inputDecoration('dd-mm-yyyy').copyWith(
//                       suffixIcon: const Icon(
//                         Icons.calendar_today_outlined,
//                         size: 16,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // BUTTONS
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       ElevatedButton(
//                         onPressed:
//                             _isSubmitting ? null : () => Navigator.pop(context),
//                         style: ElevatedButton.styleFrom(
//                           elevation: 0,
//                           backgroundColor: Colors.grey.shade100,
//                           foregroundColor: Colors.black87,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         child: const Text('Close'),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: _isSubmitting ? null : _submit,
//                         style: ElevatedButton.styleFrom(
//                           elevation: 0,
//                           backgroundColor: _primary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 22,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         child: _isSubmitting
//                             ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Text(
//                                 'Submit',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../models/projectdetails/payment_schedule/payment_schedule_model.dart';
import '../../models/projectdetails/payment_schedule/stage_model.dart';
import '../../service/service.dart';

class PaymentScheduleScreen extends StatefulWidget {
  final String projectId;
  final String projectNo;

  const PaymentScheduleScreen({
    super.key,
    required this.projectId,
    required this.projectNo,
  });

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  // OFFLINE STATE
  bool _isOffline = false;

  // LIST STATE
  bool _isLoading = true;
  List<PaymentScheduleRecord> _schedules = [];
  PaymentScheduleSummary _summary = PaymentScheduleSummary.empty();

  @override
  void initState() {
    super.initState();
    _loadPaymentSchedules();
  }

  // CHECK INTERNET
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // LOAD / REFRESH PAYMENT SCHEDULES
  Future<void> _loadPaymentSchedules() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final online = await _hasInternet();

    if (!mounted) return;

    setState(() {
      _isOffline = !online;
    });

    if (!online) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await HttpService.getPaymentSchedules(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status && response.data != null) {
        setState(() {
          _schedules = response.data!.records;
          _summary = response.data!.summary;
        });
      } else {
        setState(() {
          _schedules = [];
          _summary = PaymentScheduleSummary.empty();
        });
      }
    } catch (e) {
      log('Load payment schedules error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ADD
  void _openAddPaymentScheduleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _AddPaymentScheduleDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          onSuccess: () {
            // Refresh the payment schedule list
            _loadPaymentSchedules();
          },
        );
      },
    );
  }

  // EDIT
  void _openEditPaymentScheduleDialog(PaymentScheduleRecord item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _AddPaymentScheduleDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          schedule: item, // edit mode
          onSuccess: _loadPaymentSchedules,
        );
      },
    );
  }

  // DELETE
  Future<void> _confirmDelete(PaymentScheduleRecord item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete Payment Schedule',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final bool success = await HttpService.deletePaymentSchedule(
      projectId: widget.projectId,
      paymentId: item.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Payment schedule deleted successfully'
            : 'Failed to delete payment schedule'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) _loadPaymentSchedules();
  }

  //empty
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payment_outlined,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No payment schedules found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No project payment schedule records are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NO INTERNET STATE
  Widget _buildOfflineState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and pull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadPaymentSchedules,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARD HELPERS

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'partial':
      case 'partially paid':
        return Colors.blue;
      case 'open':
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _money(String value) {
    final n = num.tryParse(value.trim()) ?? 0;
    return '\u20B9 ${n.toStringAsFixed(2)}';
  }

  String _percent(String value) {
    final n = double.tryParse(value.trim()) ?? 0;
    if (n == n.truncateToDouble()) return '${n.toInt()}%';
    return '${n.toStringAsFixed(1)}%';
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = _primary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(PaymentScheduleRecord item) {
    final statusColor = _statusColor(item.paymentStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER: stage name + edit / delete
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              size: 21,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Stage',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.stageNames.isEmpty
                                      ? '-'
                                      : item.stageNames,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionIcon(
                            icon: Icons.edit_outlined,
                            color: _primary,
                            tooltip: 'Edit',
                            onTap: () => _openEditPaymentScheduleDialog(item),
                          ),
                          const SizedBox(width: 8),
                          _buildActionIcon(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.red,
                            tooltip: 'Delete',
                            onTap: () => _confirmDelete(item),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),

                      // ROW 1: Unit + Site Lift
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              icon: Icons.badge_rounded,
                              label: 'Unit No',
                              value: item.unitName,
                              iconColor: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDetailItem(
                              icon: Icons.label_rounded,
                              label: 'Site Lift No',
                              value: item.siteLiftName,
                              iconColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ROW 2: Percentage + Amount
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              icon: Icons.percent_rounded,
                              label: 'Percentage',
                              value: _percent(item.percentage),
                              iconColor: Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDetailItem(
                              icon: Icons.currency_rupee_rounded,
                              label: 'Amount',
                              value: _money(item.amount),
                              iconColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ROW 3: Paid + Balance (highlighted panel)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F9FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE3EBF5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.check_circle_outline_rounded,
                                label: 'Paid',
                                value: _money(item.paidAmount),
                                iconColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Balance',
                                value: _money(item.balanceAmount),
                                iconColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),

                      // FOOTER: due date (left) + lock + status (bottom right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              icon: Icons.calendar_today_rounded,
                              label: 'Due Date',
                              value: item.dueDate,
                              iconColor: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.locked)
                            Container(
                              width: 30,
                              height: 30,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.paymentStatus.isEmpty
                                      ? '-'
                                      : item.paymentStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  // FIXED BOTTOM SUMMARY BAR
  Widget _buildSummaryBar() {
    Widget cell(String label, String value) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _money(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              cell('Total', _summary.totalAmount),
              cell('Paid', _summary.totalPaidAmount),
              cell('Balance', _summary.totalBalance),
            ],
          ),
        ),
      ),
    );
  }

  // BODY (pull-to-refresh enabled)
  Widget _buildBody() {
    if (_isLoading && _schedules.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    // Offline or empty: scrollable so pull-to-refresh still works
    if (_isOffline || _schedules.isEmpty) {
      return RefreshIndicator(
        color: _primary,
        onRefresh: _loadPaymentSchedules,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: _isOffline ? _buildOfflineState() : _buildEmptyState(),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadPaymentSchedules,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          return _buildScheduleCard(_schedules[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Payment Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _openAddPaymentScheduleDialog,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primary,
                _primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _schedules.isNotEmpty && !_isOffline ? _buildSummaryBar() : null,
    );
  }
}

// ADD / EDIT PAYMENT SCHEDULE DIALOG

class _AddPaymentScheduleDialog extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final VoidCallback onSuccess;

  /// null = add mode, non-null = edit mode
  final PaymentScheduleRecord? schedule;

  const _AddPaymentScheduleDialog({
    required this.projectId,
    required this.projectNo,
    required this.onSuccess,
    this.schedule,
  });

  @override
  State<_AddPaymentScheduleDialog> createState() =>
      __AddPaymentScheduleDialogState();
}

class __AddPaymentScheduleDialogState extends State<_AddPaymentScheduleDialog> {
  static const Color _primary = Color(0xFF2A86C9);

  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.schedule != null;

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;

  List<FitStage> _selectedStages = [];

  bool _isLoadingStages = false;
  List<FitStage> _stageList = [];

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  bool _isSubmitting = false;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  // Picked due date (kept as DateTime so it can be sent as yyyy-MM-dd)
  DateTime? _dueDate;

  // Controllers for separate fields
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Prefill text fields in edit mode
    final s = widget.schedule;
    if (s != null) {
      _percentageController.text = s.percentage;
      _amountController.text = s.amount;

      final parsed = DateTime.tryParse(s.dueDateRaw);
      if (parsed != null) {
        _dueDate = parsed;
        _dueDateController.text = _formatDisplayDate(parsed);
      }
    }

    _loadUnits();
    _loadSiteLifts();
    _loadFitStages();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  String _formatDisplayDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  // LOAD UNITS API
  Future<void> _loadUnits() async {
    setState(() {
      _isLoadingUnits = true;
    });

    try {
      final response = await HttpService.getProjectDocumentUnits(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _unitList = response.data;

          // Preselect in edit mode (must be the same instance as in the list)
          if (_isEdit) {
            for (final u in _unitList) {
              if (u.id == widget.schedule!.unitNo) _selectedUnit = u;
            }
          }
        });
      }
    } catch (e) {
      log('Unit API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUnits = false;
        });
      }
    }
  }

  // LOAD SITE LIFTS API
  Future<void> _loadSiteLifts() async {
    setState(() {
      _isLoadingSiteLifts = true;
    });

    try {
      final response = await HttpService.getSiteLifts(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _siteLiftList = response.data;

          if (_isEdit) {
            for (final l in _siteLiftList) {
              if (l.id == widget.schedule!.siteLiftNo) _selectedSiteLift = l;
            }
          }
        });
      }
    } catch (e) {
      log('Site Lift API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSiteLifts = false;
        });
      }
    }
  }

  //LOAD FIT STAGES API
  Future<void> _loadFitStages() async {
    setState(() {
      _isLoadingStages = true;
    });

    try {
      final response = await HttpService.getFitStages(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _stageList = response.data;

          if (_isEdit) {
            _selectedStages = _stageList
                .where((s) => widget.schedule!.stageIds.contains(s.activityKey))
                .toList();
          }
        });
      }
    } catch (e) {
      log('Fit stages API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStages = false;
        });
      }
    }
  }

  // MULTI-SELECT STAGE PICKER
  Future<void> _openStagePicker() async {
    final List<FitStage> temp = List<FitStage>.from(_selectedStages);

    final result = await showDialog<List<FitStage>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: const Text(
                'Select Stages',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _stageList.map((stage) {
                    final bool checked =
                        temp.any((s) => s.activityKey == stage.activityKey);

                    return CheckboxListTile(
                      value: checked,
                      dense: true,
                      activeColor: _primary,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        stage.activityName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            temp.add(stage);
                          } else {
                            temp.removeWhere(
                                (s) => s.activityKey == stage.activityKey);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, temp),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Done (${temp.length})'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedStages = result;
      });
    }
  }

  // MULTI-SELECT STAGE FIELD
  Widget _buildStageMultiSelect() {
    return FormField<List<FitStage>>(
      validator: (_) =>
          _selectedStages.isEmpty ? 'This field is required' : null,
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _isLoadingStages
              ? null
              : () async {
                  await _openStagePicker();
                  state.didChange(_selectedStages);
                },
          child: InputDecorator(
            isEmpty: false,
            decoration: _inputDecoration('').copyWith(
              errorText: state.errorText,
              suffixIcon: _isLoadingStages
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            child: _selectedStages.isEmpty
                ? Text(
                    _isLoadingStages ? 'Loading...' : 'Select Stages',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _selectedStages.map((stage) {
                      return Chip(
                        label: Text(
                          stage.activityName,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _primary.withOpacity(0.10),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onDeleted: () {
                          setState(() {
                            _selectedStages.removeWhere(
                                (s) => s.activityKey == stage.activityKey);
                          });
                          state.didChange(_selectedStages);
                        },
                      );
                    }).toList(),
                  ),
          ),
        );
      },
    );
  }

  // DATE PICKER
  Future<void> _pickDueDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
        _dueDateController.text = _formatDisplayDate(date);
      });
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
    bool isLoading = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(isLoading ? 'Loading...' : hint),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.keyboard_arrow_down_rounded),
      // Set menuMaxHeight to prevent overflow if the list is long
      menuMaxHeight: 300,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Text(
                  getLabel(item),
                  // Remove overflow truncation by letting it wrap or handle max lines
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              );
            },
          ),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (val) => val == null ? 'This field is required' : null,
    );
  }

  // SUBMIT FORM (add or update)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String unitId = _selectedUnit?.id ?? '';
      final String siteLiftId = _selectedSiteLift?.id ?? '';
      final List<String> stageIds =
          _selectedStages.map((s) => s.activityKey).toList();
      final String percentage = _percentageController.text.trim();
      final String amount = _amountController.text.trim();

      // API format: yyyy-MM-dd
      final String dueDate = _dueDate == null
          ? ''
          : '${_dueDate!.year}-'
              '${_dueDate!.month.toString().padLeft(2, '0')}-'
              '${_dueDate!.day.toString().padLeft(2, '0')}';

      print(
          'Unit: $unitId, Lift: $siteLiftId, Stages: $stageIds, %: $percentage, Amt: $amount, Due: $dueDate');

      final bool success = _isEdit
          ? await HttpService.updatePaymentSchedule(
              projectId: widget.projectId,
              paymentId: widget.schedule!.id,
              unitNo: unitId,
              siteLiftNo: siteLiftId,
              stageIds: stageIds,
              amount: amount,
              percentage: percentage,
              dueDate: dueDate,
            )
          : await HttpService.addPaymentSchedule(
              projectId: widget.projectId,
              unitNo: unitId,
              siteLiftNo: siteLiftId,
              stageIds: stageIds,
              amount: amount,
              percentage: percentage,
              dueDate: dueDate,
            );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Payment schedule updated successfully'
                : 'Payment schedule added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Failed to update payment schedule'
                : 'Failed to add payment schedule'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Save payment schedule error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Failed to update payment schedule: $e'
              : 'Failed to add payment schedule: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEdit ? 'Edit Payment Schedule' : 'Payment Schedule',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 1. UNIT NO DROPDOWN
                  _buildLabel('Unit No.', required: true),
                  _buildDropdown<ProjectDocumentUnit>(
                    value: _selectedUnit,
                    hint: 'Select a Unit',
                    items: _unitList,
                    getLabel: (unit) => unit.unitNo,
                    onChanged: (value) => setState(() => _selectedUnit = value),
                    isLoading: _isLoadingUnits,
                  ),
                  const SizedBox(height: 16),

                  // 2. SITE LIFT NO DROPDOWN
                  _buildLabel('Site Lift No.', required: true),
                  _buildDropdown<SiteLift>(
                    value: _selectedSiteLift,
                    hint: 'Select Site Lift No.',
                    items: _siteLiftList,
                    getLabel: (lift) => lift.siteLiftName,
                    onChanged: (value) =>
                        setState(() => _selectedSiteLift = value),
                    isLoading: _isLoadingSiteLifts,
                  ),
                  const SizedBox(height: 16),

                  // 3. SELECT STAGES
                  _buildLabel('Select Stages', required: true),
                  _buildStageMultiSelect(),
                  const SizedBox(height: 16),

                  // 4. PERCENTAGE + AMOUNT (side by side)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Percentage'),
                            TextFormField(
                              controller: _percentageController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                'Percent',
                                prefixIcon: const Icon(
                                  Icons.percent,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Amount', required: true),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                'Amount',
                                prefixIcon: const Icon(
                                  Icons.currency_rupee,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. DUE DATE
                  _buildLabel('Due Date'),
                  TextFormField(
                    controller: _dueDateController,
                    readOnly: true,
                    onTap: _pickDueDate,
                    decoration: _inputDecoration('dd-mm-yyyy').copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEdit ? 'Update' : 'Submit',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
