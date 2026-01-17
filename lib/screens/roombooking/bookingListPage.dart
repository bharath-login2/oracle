import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/roomManagement/roomListModel.dart';
import 'package:login2/screens/roombooking/addBookingPage.dart';
import 'package:login2/screens/roombooking/create_receipt_page.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/pdfViewPage.dart';

class BookingListPage extends StatefulWidget {
  final String status;
  const BookingListPage({super.key, required this.status});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<RoomBookingData> _bookings = [];
  List<RoomBookingData> _filteredBookings = [];
  bool _isLoading = true;
  String? token;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    try {
      token = await Common.getSharedPref("token");
      if (token == null || token!.isEmpty) {
        setState(() {
          _errorMessage = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }
      await _fetchBookingData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBookingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await HttpService.getRoomList(widget.status);

      if (response != null && response.status) {
        List<RoomBookingData> allBookings = response.data;

        List<RoomBookingData> filteredBookings;
        switch (widget.status) {
          case "New":
            filteredBookings =
                allBookings.where((b) => b.statusName == "Booked").toList();
            break;
          case "Checkin":
            filteredBookings =
                allBookings.where((b) => b.statusName == "Check In").toList();
            break;
          case "Checkout":
            filteredBookings =
                allBookings.where((b) => b.statusName == "Check Out").toList();
            break;
          case "Cancelled":
            filteredBookings =
                allBookings.where((b) => b.statusName == "Cancelled").toList();
            break;
          default:
            filteredBookings = allBookings;
        }

        setState(() {
          _bookings = filteredBookings;
          _filteredBookings = filteredBookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Failed to load bookings';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Color _getPaymentStatusColor(String status) {
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'paid':
        return Colors.green;
      case 'partially paid':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Booked':
        return const Color(0xFF2196F3);
      case 'Check In':
        return const Color(0xFF4CAF50);
      case 'Check Out':
        return const Color(0xFF9C27B0);
      case 'Cancelled':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusText(String paymentStatus) {
    if (paymentStatus.isEmpty) return 'Unpaid';
    return paymentStatus;
  }

  String _getBookingTypeText(String bookingType) {
    if (bookingType.isEmpty) return 'N/A';
    return bookingType;
  }

  String _getPlatformText(String platform) {
    if (platform.isEmpty) return 'Direct';
    return platform;
  }

  String _getStayTypeText(String stayType) {
    if (stayType.isEmpty) return 'Daily';
    return stayType;
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return dateString;
  }

  String _formatDateTime(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error parsing datetime: $e');
    }

    return dateString;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBookings = _bookings;
      } else {
        _filteredBookings = _bookings.where((booking) {
          return booking.name.toLowerCase().contains(query) ||
              booking.contactNo.contains(query) ||
              booking.bookingId.toLowerCase().contains(query) ||
              booking.id.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _getPageTitle() {
    switch (widget.status) {
      case "New":
        return "New Bookings";
      case "Checkin":
        return "Check-ins";
      case "Checkout":
        return "Check-outs";
      case "Cancelled":
        return "Cancelled Bookings";
      default:
        return "All Bookings";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: _fetchBookingData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBookingPage()),
              ).then((_) {
                _fetchBookingData();
              });
            },
            tooltip: 'Add New Booking',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by guest name, phone, or booking ID...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade500),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red.shade600),
                      onPressed: () {
                        setState(() {
                          _errorMessage = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _filteredBookings.isEmpty
                    ? _buildEmptyView()
                    : _buildBookingsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookingPage()),
          ).then((_) {
            _fetchBookingData();
          });
        },
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color.fromARGB(255, 22, 145, 216),
          ),
          SizedBox(height: 16),
          Text(
            'Loading bookings...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.status == "New"
                ? 'No new bookings available'
                : widget.status == "Checkin"
                    ? 'No check-ins available'
                    : widget.status == "Checkout"
                        ? 'No check-outs available'
                        : 'No cancelled bookings',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (_errorMessage.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchBookingData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 145, 216),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return RefreshIndicator(
      onRefresh: _fetchBookingData,
      color: const Color.fromARGB(255, 22, 145, 216),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredBookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final booking = _filteredBookings[index];
          return _buildBookingCard(booking, index + 1);
        },
      ),
    );
  }

  Widget _buildBookingCard(RoomBookingData booking, int serialNo) {
    final paymentStatus = _getPaymentStatusText(booking.paymentStatus);
    final bookingType = _getBookingTypeText(booking.bookingType);
    final platform = _getPlatformText(booking.platform);
    final stayType = _getStayTypeText(booking.stayType);
    final checkInDate = _formatDate(booking.checkInDate);
    final checkOutDate = _formatDate(booking.checkOutDate);
    final bookingDate = _formatDateTime(booking.bookingDate);
    final roomNumber = booking.roomNumber.isEmpty ? 'N/A' : booking.roomNumber;
    final amount = booking.amount.isEmpty ? '0' : booking.amount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showBookingDetails(booking);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Center(
                        child: Text(
                          serialNo.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.contactNo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.statusName)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _getStatusColor(booking.statusName)
                                .withOpacity(0.3)),
                      ),
                      child: Text(
                        booking.statusName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(booking.statusName),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check In',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              checkInDate,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Type',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stayType,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(paymentStatus)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                paymentStatus,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getPaymentStatusColor(paymentStatus),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booked on $bookingDate',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.business,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              platform,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.type_specimen,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              bookingType,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showBookingDetails(booking);
                          },
                          icon: Icon(Icons.visibility_outlined,
                              size: 20, color: Colors.blue.shade600),
                          tooltip: 'View Details',
                        ),
                        IconButton(
                          onPressed: () {
                            _editBooking(booking.id);
                          },
                          icon: Icon(Icons.edit_outlined,
                              size: 20, color: Colors.green.shade600),
                          tooltip: 'Edit',
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert,
                              color: Colors.grey.shade600),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'createreceipt',
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_outlined,
                                      size: 18, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Create Receipt'),
                                ],
                              ),
                            ),
                            // const PopupMenuItem(
                            //   value: 'checkout',
                            //   child: Row(
                            //     children: [
                            //       Icon(Icons.details, size: 18, color: Colors.blue),
                            //       SizedBox(width: 8),
                            //       Text('View Details'),
                            //     ],
                            //   ),
                            // ),
                            const PopupMenuItem(
                              value: 'receipt',
                              child: Row(
                                children: [
                                  Icon(Icons.print,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Print'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'checkin') {
                              _checkInBooking(booking);
                            } else if (value == 'createreceipt') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateReceiptPage(
                                    booking: booking,
                                  ),
                                ),
                              );
                            } else if (value == 'receipt') {
                              final pdfBytes = await HttpService()
                                  .fetchInvoicePdfBytes(booking.id.toString());

                              if (pdfBytes != null && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PdfMemoryView(bytes: pdfBytes),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Unable to load invoice PDF")),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(RoomBookingData booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BookingDetailsSheet(booking: booking),
    );
  }

  void _editBooking(String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookingPage(
          bookingId: bookingId,
        ),
      ),
    );
  }

  void _checkInBooking(RoomBookingData booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-in Booking'),
        content: Text('Check-in ${booking.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking.name} checked in successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Check-in'),
          ),
        ],
      ),
    );
  }

  void _checkOutBooking(RoomBookingData booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-out Booking'),
        content: Text('Check-out ${booking.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking.name} checked out successfully'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Check-out'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(RoomBookingData booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking for ${booking.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking.name} booking cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final RoomBookingData booking;

  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color getPaymentStatusColor(String status) {
      final statusLower = status.toLowerCase();
      switch (statusLower) {
        case 'paid':
          return Colors.green;
        case 'partially paid':
          return Colors.orange;
        case 'unpaid':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    Color getStatusColor(String status) {
      switch (status) {
        case 'Booked':
          return const Color(0xFF2196F3);
        case 'Check In':
          return const Color(0xFF4CAF50);
        case 'Check Out':
          return const Color(0xFF9C27B0);
        case 'Cancelled':
          return const Color(0xFFF44336);
        default:
          return Colors.grey;
      }
    }

    String _formatDate(String dateString) {
      if (dateString.isEmpty) return 'N/A';

      try {
        final dateTime = DateTime.tryParse(dateString);
        if (dateTime != null) {
          return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
        }
      } catch (e) {
        print('Error parsing date: $e');
      }

      return dateString;
    }

    String _formatDateTime(String dateString) {
      if (dateString.isEmpty) return 'N/A';

      try {
        final dateTime = DateTime.tryParse(dateString);
        if (dateTime != null) {
          return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        print('Error parsing datetime: $e');
      }

      return dateString;
    }

    String getText(String value) => value.isEmpty ? 'N/A' : value;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      booking.name.isNotEmpty
                          ? booking.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.contactNo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildDetailItem('Booking ID', getText(booking.bookingId)),
              _buildDetailItem('Check-in', _formatDate(booking.checkInDate)),
              _buildDetailItem('Check-out', _formatDate(booking.checkOutDate)),
              _buildDetailItem('Stay Type', getText(booking.stayType)),
              _buildDetailItem('Booking Type', getText(booking.bookingType)),
              _buildDetailItem('Platform', getText(booking.platform)),
              _buildDetailItem(
                  'Booking Date', _formatDateTime(booking.bookingDate)),
              _buildDetailItem('Room', getText(booking.roomNumber)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.currency_rupee, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Amount: ₹${getText(booking.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Payment Status',
                  booking.paymentStatus.isEmpty
                      ? 'Unpaid'
                      : booking.paymentStatus,
                  getPaymentStatusColor(booking.paymentStatus.isEmpty
                      ? 'unpaid'
                      : booking.paymentStatus),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Booking Status',
                  booking.statusName,
                  getStatusColor(booking.statusName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
