import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final ApiService api = ApiService();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // ============================================================
  // COLORS
  // ============================================================

  final Color backgroundColor = const Color(0xFF071A33);
  final Color cardColor = const Color(0xFF102846);
  final Color borderColor = const Color(0xFF294566);
  final Color primaryColor = const Color(0xFF216BFF);
  final Color secondaryColor = const Color(0xFF7189AA);

  // ============================================================
  // STATE
  // ============================================================

  List<dynamic> bookings = [];

  bool loading = true;
  bool deleting = false;

  String customerEmail = '';

  String errorMessage = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadBookings();
  }

  // ============================================================
  // LOAD BOOKINGS
  // ============================================================

  Future<void> loadBookings() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      String? savedEmail = await secureStorage.read(key: 'user_email');

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        savedEmail = await secureStorage.read(key: 'saved_email');
      }

      final email = savedEmail?.trim().toLowerCase() ?? '';

      debugPrint('==========================================');
      debugPrint('MY BOOKINGS');
      debugPrint('USER EMAIL: $email');
      debugPrint('==========================================');

      if (email.isEmpty) {
        throw Exception('Please login again to view your bookings.');
      }

      final result = await api.getBookings(email);

      debugPrint('BOOKINGS RECEIVED: ${result.length}');

      if (!mounted) return;

      setState(() {
        customerEmail = email;
        bookings = result;
        loading = false;
        errorMessage = '';
      });
    } catch (e) {
      debugPrint('MY BOOKINGS ERROR: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = _cleanError(e);
        bookings = [];
      });
    }
  }

  // ============================================================
  // PULL TO REFRESH
  // ============================================================

  Future<void> refreshBookings() async {
    try {
      String? savedEmail = await secureStorage.read(key: 'user_email');

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        savedEmail = await secureStorage.read(key: 'saved_email');
      }

      final email = savedEmail?.trim().toLowerCase() ?? '';

      if (email.isEmpty) {
        throw Exception('Please login again to view your bookings.');
      }

      final result = await api.getBookings(email);

      if (!mounted) return;

      setState(() {
        customerEmail = email;
        bookings = result;
        errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // DELETE / CANCEL BOOKING
  // ============================================================

  Future<void> cancelBooking(dynamic booking) async {
    final bookingId = _getBookingId(booking);

    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid booking ID.'),
          backgroundColor: Colors.redAccent,
        ),
      );

      return;
    }

    // ============================================================
    // CONFIRMATION DIALOG
    // ============================================================

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cancel Booking?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to cancel this booking? '
            'This action cannot be undone.',
            style: TextStyle(color: Color(0xFF8DA1BD), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Keep Booking',
                style: TextStyle(
                  color: Color(0xFF8DA1BD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Cancel Booking',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      deleting = true;
    });

    try {
      debugPrint('==========================================');
      debugPrint('CANCEL BOOKING');
      debugPrint('BOOKING ID: $bookingId');
      debugPrint('==========================================');

      final success = await api.deleteBooking(bookingId);

      if (!mounted) return;

      if (success) {
        setState(() {
          bookings.removeWhere((item) => _getBookingId(item) == bookingId);

          deleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully.'),
            backgroundColor: Color(0xFF35D07F),
          ),
        );
      } else {
        setState(() {
          deleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to cancel booking.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('CANCEL BOOKING ERROR: $e');

      if (!mounted) return;

      setState(() {
        deleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancellation failed: ${_cleanError(e)}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // GET BOOKING ID
  // ============================================================

  int? _getBookingId(dynamic booking) {
    if (booking is! Map) return null;

    final value =
        booking['booking_id'] ?? booking['id'] ?? booking['bookingId'];

    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  // ============================================================
  // GET VALUE
  // ============================================================

  String _getValue(dynamic booking, List<String> keys, {String fallback = ''}) {
    if (booking is! Map) return fallback;

    for (final key in keys) {
      final value = booking[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  // ============================================================
  // PROVIDER NAME
  // ============================================================

  String _providerName(dynamic booking) {
    if (booking is! Map) {
      return 'Service Provider';
    }

    final direct = _getValue(booking, [
      'provider_name',
      'providerName',
      'provider',
      'name',
    ]);

    // FIX:
    // _getValue() already returns String,
    // so there is no need for "direct is String".

    if (direct.isNotEmpty && direct != 'null') {
      return direct;
    }

    final provider = booking['provider'];

    if (provider is Map) {
      return _getValue(provider, [
        'name',
        'provider_name',
      ], fallback: 'Service Provider');
    }

    return 'Service Provider';
  }

  // ============================================================
  // SERVICE NAME
  // ============================================================

  String _serviceName(dynamic booking) {
    return _getValue(booking, [
      'service',
      'service_name',
      'serviceName',
    ], fallback: 'Service');
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(dynamic booking) {
    final value = _getValue(booking, ['service_date', 'serviceDate', 'date']);

    if (value.isEmpty) {
      return 'Date not available';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // TIME
  // ============================================================

  String _formatTime(dynamic booking) {
    final value = _getValue(booking, ['service_time', 'serviceTime', 'time']);

    if (value.isEmpty) {
      return 'Time not available';
    }

    try {
      final parts = value.split(':');

      if (parts.length < 2) {
        return value;
      }

      int hour = int.parse(parts[0]);

      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

      hour = hour % 12;

      if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  String _address(dynamic booking) {
    return _getValue(booking, [
      'address',
      'service_address',
      'serviceAddress',
    ], fallback: 'Address not available');
  }

  // ============================================================
  // NOTES
  // ============================================================

  String _notes(dynamic booking) {
    return _getValue(booking, ['notes', 'note']);
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _status(dynamic booking) {
    return _getValue(booking, [
      'status',
      'booking_status',
      'bookingStatus',
    ], fallback: 'Confirmed');
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('cancel')) {
      return Colors.redAccent;
    }

    if (value.contains('complete')) {
      return const Color(0xFF35D07F);
    }

    if (value.contains('pending')) {
      return Colors.orangeAccent;
    }

    return const Color(0xFF35D07F);
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(dynamic error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    return message;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'My Bookings',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),

        actions: [
          IconButton(
            onPressed: loading ? null : loadBookings,
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF216BFF),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Loading your bookings...',
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    // ==========================================================
    // BOOKINGS
    // ==========================================================

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: refreshBookings,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),

        itemCount: bookings.length,

        itemBuilder: (context, index) {
          final booking = bookings[index];

          return _buildBookingCard(booking, index);
        },
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 72,
              width: 72,

              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load bookings',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              errorMessage,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: secondaryColor,
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 45,

              child: ElevatedButton.icon(
                onPressed: loadBookings,

                icon: const Icon(Icons.refresh_rounded, size: 18),

                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,

                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: refreshBookings,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),

          Center(
            child: Container(
              height: 85,
              width: 85,

              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.calendar_month_rounded,
                color: primaryColor,
                size: 40,
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Center(
            child: Text(
              'No Bookings Yet',

              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 9),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),

            child: Text(
              'You have not booked any services yet. '
              'Book a service and it will appear here.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: secondaryColor,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: TextButton.icon(
              onPressed: refreshBookings,

              icon: const Icon(Icons.refresh_rounded, size: 18),

              label: const Text(
                'Refresh',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),

              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _buildBookingCard(dynamic booking, int index) {
    final providerName = _providerName(booking);

    final service = _serviceName(booking);

    final date = _formatDate(booking);

    final time = _formatTime(booking);

    final address = _address(booking);

    final notes = _notes(booking);

    final status = _status(booking);

    final bookingId = _getBookingId(booking);

    final firstLetter = providerName.isNotEmpty
        ? providerName[0].toUpperCase()
        : 'P';

    final statusColor = _statusColor(status);

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),

      child: Column(
        children: [
          // ====================================================
          // TOP SECTION
          // ====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==============================================
                // PROVIDER AVATAR
                // ==============================================
                Container(
                  height: 50,
                  width: 50,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF216BFF), Color(0xFF604DE4)],
                    ),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Center(
                    child: Text(
                      firstLetter,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ==============================================
                // PROVIDER DETAILS
                // ==============================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        providerName,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        service.toUpperCase(),

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),

                      if (bookingId != null) ...[
                        const SizedBox(height: 5),

                        Text(
                          'Booking #$bookingId',

                          style: TextStyle(color: secondaryColor, fontSize: 9),
                        ),
                      ],
                    ],
                  ),
                ),

                // ==============================================
                // STATUS
                // ==============================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Container(
                        height: 6,
                        width: 6,

                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        status,

                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // DIVIDER
          // ====================================================
          Divider(height: 1, color: borderColor),

          // ====================================================
          // DATE / TIME
          // ====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 8),

            child: Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'DATE',
                    value: date,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _infoItem(
                    icon: Icons.access_time_rounded,
                    label: 'TIME',
                    value: time,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // ADDRESS
          // ====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),

            child: _addressItem(address),
          ),

          // ====================================================
          // NOTES
          // ====================================================
          if (notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 6, 15, 8),

              child: _notesItem(notes),
            ),

          // ====================================================
          // CANCEL BUTTON
          // ====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),

            child: SizedBox(
              width: double.infinity,
              height: 43,

              child: OutlinedButton.icon(
                onPressed: deleting ? null : () => cancelBooking(booking),

                icon: const Icon(Icons.cancel_outlined, size: 18),

                label: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,

                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.45),
                  ),

                  disabledForegroundColor: Colors.redAccent.withValues(
                    alpha: 0.35,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: const Color(0xFF0B203A),
        borderRadius: BorderRadius.circular(11),
      ),

      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADDRESS ITEM
  // ============================================================

  Widget _addressItem(String address) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: const Color(0xFF0B203A),
        borderRadius: BorderRadius.circular(11),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.location_on_outlined, color: primaryColor, size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'SERVICE ADDRESS',

                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  address,

                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES ITEM
  // ============================================================

  Widget _notesItem(String notes) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: const Color(0xFF0B203A),
        borderRadius: BorderRadius.circular(11),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.notes_rounded, color: primaryColor, size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'ADDITIONAL NOTES',

                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  notes,

                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
