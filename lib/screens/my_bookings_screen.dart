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
  // STATE
  // ============================================================

  bool loading = true;

  String? error;

  List<dynamic> bookings = [];

  String customerEmail = '';

  static const String emailKey = 'user_email';

  // ============================================================
  // COLORS
  // ============================================================

  final Color backgroundColor = const Color(0xFF071A33);

  final Color cardColor = const Color(0xFF102846);

  final Color borderColor = const Color(0xFF294566);

  final Color primaryColor = const Color(0xFF216BFF);

  final Color secondaryColor = const Color(0xFF7189AA);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadUserEmail();
  }

  // ============================================================
  // LOAD USER EMAIL
  // ============================================================

  Future<void> loadUserEmail() async {
    try {
      String? savedEmail = await secureStorage.read(key: emailKey);

      // ----------------------------------------------------------
      // FALLBACK
      // ----------------------------------------------------------

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        savedEmail = await secureStorage.read(key: 'saved_email');
      }

      // ----------------------------------------------------------
      // IMPORTANT:
      // Check mounted after async operation.
      // ----------------------------------------------------------

      if (!mounted) return;

      // ----------------------------------------------------------
      // NO USER
      // ----------------------------------------------------------

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        setState(() {
          loading = false;
          error = 'No logged-in user found.';
        });

        return;
      }

      // ----------------------------------------------------------
      // SAVE EMAIL
      // ----------------------------------------------------------

      final email = savedEmail.trim().toLowerCase();

      setState(() {
        customerEmail = email;
      });

      debugPrint('================================');
      debugPrint('MY BOOKINGS');
      debugPrint('CUSTOMER EMAIL: $customerEmail');
      debugPrint('================================');

      // ----------------------------------------------------------
      // LOAD BOOKINGS
      // ----------------------------------------------------------

      await loadBookings();

      if (!mounted) return;
    } catch (e) {
      debugPrint('LOAD USER EMAIL ERROR: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'Unable to get logged-in user.';
      });
    }
  }

  // ============================================================
  // LOAD BOOKINGS
  // ============================================================

  Future<void> loadBookings() async {
    // ----------------------------------------------------------
    // CHECK EMAIL
    // ----------------------------------------------------------

    if (customerEmail.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'No logged-in user found.';
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      debugPrint('================================');
      debugPrint('LOADING BOOKINGS');
      debugPrint('EMAIL: $customerEmail');
      debugPrint('================================');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final result = await api.getBookings(customerEmail);

      debugPrint('BOOKINGS API RESULT: $result');

      debugPrint('BOOKINGS TYPE: ${result.runtimeType}');

      // ----------------------------------------------------------
      // IMPORTANT:
      // Check mounted after API call.
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        bookings = result;
        loading = false;
        error = null;
      });
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('LOAD BOOKINGS ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('================================');

      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // DELETE BOOKING
  // ============================================================

  Future<void> deleteBooking(int bookingId) async {
    // ==========================================================
    // CONFIRMATION DIALOG
    // ==========================================================

    if (!mounted) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          title: const Text(
            'Delete Booking?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),

          content: const Text(
            'Are you sure you want to delete this booking? '
            'This action cannot be undone.',
            style: TextStyle(color: Color(0xFF9AAEC7), fontSize: 13),
          ),

          actions: [
            // ----------------------------------------------------
            // CANCEL
            // ----------------------------------------------------
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },

              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8EA3BE)),
              ),
            ),

            // ----------------------------------------------------
            // DELETE
            // ----------------------------------------------------
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
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    // ==========================================================
    // CHECK AFTER DIALOG
    // ==========================================================

    if (!mounted) return;

    if (confirmed != true) {
      return;
    }

    // ==========================================================
    // SHOW LOADING DIALOG
    // ==========================================================

    if (!mounted) return;

    showDialog<void>(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF216BFF)),
        );
      },
    );

    // ==========================================================
    // DELETE FROM API
    // ==========================================================

    try {
      debugPrint('================================');
      debugPrint('DELETE BOOKING');
      debugPrint('BOOKING ID: $bookingId');
      debugPrint('================================');

      final success = await api.deleteBooking(bookingId);

      debugPrint('DELETE RESULT: $success');

      // ========================================================
      // CHECK AFTER API CALL
      // ========================================================

      if (!mounted) return;

      // ========================================================
      // CLOSE LOADING DIALOG
      // ========================================================

      Navigator.of(context).pop();

      // ========================================================
      // SUCCESS
      // ========================================================

      if (success) {
        setState(() {
          bookings.removeWhere(
            (booking) =>
                booking['booking_id']?.toString() == bookingId.toString(),
          );
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking deleted successfully'),
            backgroundColor: Color(0xFF1D9E62),
          ),
        );
      }
    } catch (e) {
      debugPrint('DELETE BOOKING ERROR: $e');

      // ========================================================
      // CHECK BEFORE USING CONTEXT
      // ========================================================

      if (!mounted) return;

      // ========================================================
      // CLOSE LOADING DIALOG
      // ========================================================

      Navigator.of(context).pop();

      // ========================================================
      // SHOW ERROR
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete booking: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return '${parsed.day.toString().padLeft(2, '0')}/'
          '${parsed.month.toString().padLeft(2, '0')}/'
          '${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget bookingCard(Map<String, dynamic> booking) {
    // ----------------------------------------------------------
    // PROVIDER
    // ----------------------------------------------------------

    final provider = booking['provider'] is Map
        ? Map<String, dynamic>.from(booking['provider'])
        : <String, dynamic>{};

    // ----------------------------------------------------------
    // VALUES
    // ----------------------------------------------------------

    final String providerName = provider['name']?.toString() ?? 'Provider';

    final String service = provider['service']?.toString() ?? 'Service';

    final String price = provider['price']?.toString() ?? '0';

    final String date = booking['service_date']?.toString() ?? '';

    final String time = booking['service_time']?.toString() ?? '';

    final String address = booking['address']?.toString() ?? '';

    final String notes = booking['notes']?.toString() ?? '';

    final String status = booking['status']?.toString() ?? 'confirmed';

    final int? bookingId = int.tryParse(
      booking['booking_id']?.toString() ?? '',
    );

    final String firstLetter = providerName.isNotEmpty
        ? providerName[0].toUpperCase()
        : 'P';

    // ==========================================================
    // CARD
    // ==========================================================

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(19),

        border: Border.all(color: borderColor),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // PROVIDER ROW
          // ====================================================
          Row(
            children: [
              // ------------------------------------------------
              // AVATAR
              // ------------------------------------------------
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

              // ------------------------------------------------
              // PROVIDER DETAILS
              // ------------------------------------------------
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      service.toUpperCase(),

                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // STATUS
              // ------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF35D07F).withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  status.toUpperCase(),

                  style: const TextStyle(
                    color: Color(0xFF35D07F),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ====================================================
          // DATE + TIME
          // ====================================================
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  Icons.calendar_month_rounded,
                  'DATE',
                  formatDate(date),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _infoRow(Icons.access_time_rounded, 'TIME', time),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ====================================================
          // ADDRESS
          // ====================================================
          _infoRow(Icons.location_on_outlined, 'ADDRESS', address),

          // ====================================================
          // NOTES
          // ====================================================
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 15),

            _infoRow(Icons.notes_rounded, 'NOTES', notes),
          ],

          const SizedBox(height: 17),

          // ====================================================
          // PRICE
          // ====================================================
          Container(
            padding: const EdgeInsets.only(top: 14),

            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF294566))),
            ),

            child: Row(
              children: [
                Text(
                  'Service Price',

                  style: TextStyle(color: secondaryColor, fontSize: 11),
                ),

                const Spacer(),

                Text(
                  '₹$price / hour',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ====================================================
          // DELETE BUTTON
          // ====================================================
          SizedBox(
            width: double.infinity,

            height: 42,

            child: OutlinedButton.icon(
              onPressed: bookingId == null
                  ? null
                  : () {
                      deleteBooking(bookingId);
                    },

              icon: const Icon(Icons.delete_outline_rounded, size: 18),

              label: const Text(
                'Delete Booking',

                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,

                side: const BorderSide(color: Colors.redAccent),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, color: primaryColor, size: 18),

        const SizedBox(width: 8),

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
                value.isEmpty ? '-' : value,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        color: primaryColor,

        backgroundColor: cardColor,

        onRefresh: loadBookings,

        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF216BFF)),
              )
            : error != null
            ? _buildError()
            : bookings.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

                itemCount: bookings.length,

                itemBuilder: (context, index) {
                  final booking = Map<String, dynamic>.from(bookings[index]);

                  return bookingCard(booking);
                },
              ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),

        Icon(Icons.calendar_today_outlined, color: secondaryColor, size: 65),

        const SizedBox(height: 18),

        const Center(
          child: Text(
            'No bookings yet',

            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Text(
            'Your confirmed services '
            'will appear here.',

            style: TextStyle(color: secondaryColor, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.all(20),

      children: [
        const SizedBox(height: 120),

        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 55,
        ),

        const SizedBox(height: 15),

        const Center(
          child: Text(
            'Unable to load bookings',

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          error ?? 'Something went wrong',

          textAlign: TextAlign.center,

          style: TextStyle(color: secondaryColor, fontSize: 11),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 45,

          child: ElevatedButton(
            onPressed: customerEmail.isEmpty ? loadUserEmail : loadBookings,

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,

              foregroundColor: Colors.white,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),

            child: const Text(
              'Try Again',

              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
