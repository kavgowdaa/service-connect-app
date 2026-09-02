import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Map provider;

  const BookingScreen({super.key, required this.provider});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController addressController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

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

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool booking = false;

  String customerEmail = '';
  String customerName = 'Customer';

  bool loadingUser = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // IMPORTANT:
    // Load the ACTUAL logged-in user.
    loadUserDetails();
  }

  // ============================================================
  // LOAD USER DETAILS
  // ============================================================

  // ============================================================
  // LOAD LOGGED-IN USER DETAILS
  // ============================================================

  Future<void> loadUserDetails() async {
    try {
      // ----------------------------------------------------------
      // FIRST: GET ACTUAL LOGGED-IN EMAIL
      // ----------------------------------------------------------

      String? savedEmail = await secureStorage.read(key: 'user_email');

      // ----------------------------------------------------------
      // FALLBACK: saved_email
      // ----------------------------------------------------------

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        savedEmail = await secureStorage.read(key: 'saved_email');
      }

      // ----------------------------------------------------------
      // GET LOGGED-IN USER NAME
      // ----------------------------------------------------------

      final savedName = await secureStorage.read(key: 'user_name');

      // ----------------------------------------------------------
      // GET LOGIN STATUS
      // ----------------------------------------------------------

      final loggedIn = await secureStorage.read(key: 'logged_in');

      debugPrint('==========================================');
      debugPrint('BOOKING - CHECKING LOGIN');
      debugPrint('LOGGED IN: $loggedIn');
      debugPrint('USER EMAIL: $savedEmail');
      debugPrint('USER NAME: $savedName');
      debugPrint('==========================================');

      if (!mounted) return;

      setState(() {
        customerEmail = savedEmail?.trim().toLowerCase() ?? '';

        if (savedName != null && savedName.trim().isNotEmpty) {
          customerName = savedName.trim();
        } else if (customerEmail.isNotEmpty) {
          customerName = customerEmail.split('@').first;
        } else {
          customerName = 'Customer';
        }

        loadingUser = false;
      });
    } catch (e) {
      debugPrint('LOAD BOOKING USER DETAILS ERROR: $e');

      if (!mounted) return;

      setState(() {
        loadingUser = false;
        customerEmail = '';
        customerName = 'Customer';
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    addressController.dispose();
    notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> selectDate() async {
    final today = DateTime.now();

    final date = await showDatePicker(
      context: context,

      initialDate: today.add(const Duration(days: 1)),

      firstDate: today,

      lastDate: today.add(const Duration(days: 90)),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF216BFF),
              surface: Color(0xFF102846),
            ),
          ),

          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // ============================================================
  // TIME
  // ============================================================

  Future<void> selectTime() async {
    final selected = await showTimePicker(
      context: context,

      initialTime: TimeOfDay.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF216BFF),
              surface: Color(0xFF102846),
            ),
          ),

          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        selectedTime = selected;
      });
    }
  }

  // ============================================================
  // CONFIRM BOOKING
  // ============================================================

  Future<void> confirmBooking() async {
    // ============================================================
    // VALIDATE USER
    // ============================================================

    if (customerEmail.trim().isEmpty) {
      await loadUserDetails();

      if (!mounted) return;

      if (customerEmail.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login again before booking a service.'),
          ),
        );

        return;
      }
    }

    // ============================================================
    // VALIDATE DATE
    // ============================================================

    if (selectedDate == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service date')),
      );

      return;
    }

    // ============================================================
    // VALIDATE TIME
    // ============================================================

    if (selectedTime == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service time')),
      );

      return;
    }

    // ============================================================
    // VALIDATE ADDRESS
    // ============================================================

    if (addressController.text.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your service address')),
      );

      return;
    }

    // ============================================================
    // START BOOKING
    // ============================================================

    if (!mounted) return;

    setState(() {
      booking = true;
    });

    try {
      // ============================================================
      // FORMAT DATE
      // ============================================================

      final String serviceDate =
          '${selectedDate!.year}-'
          '${selectedDate!.month.toString().padLeft(2, '0')}-'
          '${selectedDate!.day.toString().padLeft(2, '0')}';

      // ============================================================
      // FORMAT TIME
      // ============================================================
      //
      // FastAPI expects:
      //
      // HH:MM
      //
      // Example:
      // 5:38 PM -> 17:38
      //
      // ============================================================

      final String serviceTime =
          '${selectedTime!.hour.toString().padLeft(2, '0')}:'
          '${selectedTime!.minute.toString().padLeft(2, '0')}';

      // ============================================================
      // PROVIDER ID
      // ============================================================

      final providerId = int.tryParse(widget.provider['id'].toString());

      if (providerId == null) {
        throw Exception('Invalid provider ID');
      }

      // ============================================================
      // USER DETAILS
      // ============================================================

      final finalEmail = customerEmail.trim().toLowerCase();

      final finalName = customerName.trim().isEmpty
          ? finalEmail.split('@').first
          : customerName.trim();

      // ============================================================
      // ADDRESS + NOTES
      // ============================================================

      final address = addressController.text.trim();

      final notes = notesController.text.trim();

      // ============================================================
      // DEBUG
      // ============================================================

      debugPrint('==========================================');
      debugPrint('CREATING BOOKING');
      debugPrint('PROVIDER ID: $providerId');
      debugPrint('CUSTOMER NAME: $finalName');
      debugPrint('CUSTOMER EMAIL: $finalEmail');
      debugPrint('DATE: $serviceDate');
      debugPrint('TIME: $serviceTime');
      debugPrint('ADDRESS: $address');
      debugPrint('NOTES: $notes');
      debugPrint('==========================================');

      // ============================================================
      // API CALL
      // ============================================================

      final result = await api.createBooking(
        providerId: providerId,
        customerName: finalName,
        customerEmail: finalEmail,
        serviceDate: serviceDate,
        serviceTime: serviceTime,
        address: address,
        notes: notes,
      );

      debugPrint('BOOKING SUCCESS: $result');

      // ============================================================
      // IMPORTANT:
      // API CALL WAS ASYNC.
      // CHECK mounted BEFORE USING STATE/CONTEXT.
      // ============================================================

      if (!mounted) return;

      setState(() {
        booking = false;
      });

      // ============================================================
      // BOOKING DATA
      // ============================================================

      final bookingData = result['booking'] is Map
          ? Map<String, dynamic>.from(result['booking'] as Map)
          : <String, dynamic>{};

      final bookingId = bookingData['booking_id']?.toString() ?? '';

      final providerName = widget.provider['name']?.toString() ?? 'Provider';

      // ============================================================
      // SUCCESS DIALOG
      // ============================================================

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: cardColor,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===================================================
                // SUCCESS ICON
                // ===================================================
                Container(
                  height: 65,
                  width: 65,

                  decoration: BoxDecoration(
                    color: const Color(0xFF35D07F).withValues(alpha: 0.15),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF35D07F),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                // ===================================================
                // TITLE
                // ===================================================
                const Text(
                  'Booking Confirmed!',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                // ===================================================
                // MESSAGE
                // ===================================================
                Text(
                  'Your booking with '
                  '$providerName '
                  'has been confirmed.',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(0xFF8DA1BD),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 15),

                // ===================================================
                // BOOKING ID
                // ===================================================
                if (bookingId.isNotEmpty)
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(11),

                    decoration: BoxDecoration(
                      color: const Color(0xFF0B203A),

                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      'Booking ID: #$bookingId',

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Color(0xFF4B8BFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // ===================================================
                // DONE
                // ===================================================
                SizedBox(
                  width: double.infinity,
                  height: 45,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),

                    child: const Text(
                      'Done',

                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      // ============================================================
      // IMPORTANT:
      // showDialog() IS ALSO ASYNC.
      // CHECK mounted AGAIN.
      // ============================================================

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('==========================================');
      debugPrint('BOOKING ERROR: $e');
      debugPrint('==========================================');

      // ============================================================
      // IMPORTANT:
      // API CALL WAS ASYNC.
      // CHECK mounted BEFORE USING CONTEXT.
      // ============================================================

      if (!mounted) return;

      setState(() {
        booking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${e.toString()}'),

          backgroundColor: Colors.redAccent,

          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate() {
    if (selectedDate == null) {
      return 'Select date';
    }

    return '${selectedDate!.day}/'
        '${selectedDate!.month}/'
        '${selectedDate!.year}';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String formatTime() {
    if (selectedTime == null) {
      return 'Select time';
    }

    return selectedTime!.format(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    final String name = provider['name']?.toString() ?? 'Provider';

    final String service = provider['service']?.toString() ?? 'Service';

    final String price = provider['price']?.toString() ?? '0';

    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    // ==========================================================
    // LOADING USER
    // ==========================================================

    if (loadingUser) {
      return Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          backgroundColor: backgroundColor,

          foregroundColor: Colors.white,

          elevation: 0,
        ),

        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF216BFF)),
        ),
      );
    }

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
          'Book Service',

          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // PROVIDER CARD
            // ==================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: borderColor),
              ),

              child: Row(
                children: [
                  // =================================================
                  // AVATAR
                  // =================================================
                  Container(
                    height: 45,
                    width: 45,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF216BFF), Color(0xFF604DE4)],
                      ),

                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: Center(
                      child: Text(
                        firstLetter,

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // =================================================
                  // PROVIDER
                  // =================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          name,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 15,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          service.toUpperCase(),

                          style: TextStyle(
                            color: secondaryColor,

                            fontSize: 10,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // PRICE
                  // =================================================
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        '₹$price',

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 15,

                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      Text(
                        '/hour',

                        style: TextStyle(color: secondaryColor, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // SCHEDULE
            // ==================================================
            const Text(
              'Schedule Service',

              style: TextStyle(
                color: Colors.white,

                fontSize: 17,

                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                // =================================================
                // DATE
                // =================================================
                Expanded(
                  child: _buildSelectionField(
                    icon: Icons.calendar_month_rounded,

                    label: 'DATE',

                    value: formatDate(),

                    onTap: selectDate,
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // TIME
                // =================================================
                Expanded(
                  child: _buildSelectionField(
                    icon: Icons.access_time_rounded,

                    label: 'TIME',

                    value: formatTime(),

                    onTap: selectTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==================================================
            // ADDRESS
            // ==================================================
            const Text(
              'Service Address',

              style: TextStyle(
                color: Colors.white,

                fontSize: 17,

                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            _buildInputField(
              controller: addressController,

              icon: Icons.location_on_outlined,

              hint: 'Enter your complete address',

              maxLines: 2,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // NOTES
            // ==================================================
            const Text(
              'Additional Notes',

              style: TextStyle(
                color: Colors.white,

                fontSize: 17,

                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            _buildInputField(
              controller: notesController,

              icon: Icons.notes_rounded,

              hint: 'Anything the provider should know?',

              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // ==================================================
            // CONFIRM BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,

              height: 52,

              child: ElevatedButton(
                onPressed: booking ? null : confirmBooking,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,

                  foregroundColor: Colors.white,

                  disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),

                child: booking
                    ? const SizedBox(
                        height: 22,

                        width: 22,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,

                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20),

                          SizedBox(width: 8),

                          Text(
                            'Confirm Booking',

                            style: TextStyle(
                              fontSize: 15,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                'Your information is kept secure',

                style: TextStyle(color: secondaryColor, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE / TIME FIELD
  // ============================================================

  Widget _buildSelectionField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(14),

      child: Container(
        padding: const EdgeInsets.all(13),

        decoration: BoxDecoration(
          color: cardColor,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: borderColor),
        ),

        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4B8BFF), size: 21),

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

                      letterSpacing: 0.6,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    value,

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
        ),
      ),
    );
  }

  // ============================================================
  // TEXT INPUT FIELD
  // ============================================================

  Widget _buildInputField({
    required TextEditingController controller,

    required IconData icon,

    required String hint,

    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: borderColor),
      ),

      child: TextField(
        controller: controller,

        maxLines: maxLines,

        style: const TextStyle(color: Colors.white, fontSize: 13),

        cursorColor: primaryColor,

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(color: secondaryColor, fontSize: 12),

          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 22 : 0),

            child: Icon(icon, color: secondaryColor, size: 20),
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,

            vertical: 13,
          ),
        ),
      ),
    );
  }
}
