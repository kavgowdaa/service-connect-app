import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final Map provider;

  const BookingScreen({super.key, required this.provider});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController addressController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  bool booking = false;

  final Color backgroundColor = const Color(0xFF071A33);
  final Color cardColor = const Color(0xFF102846);
  final Color borderColor = const Color(0xFF294566);
  final Color primaryColor = const Color(0xFF216BFF);
  final Color secondaryColor = const Color(0xFF7189AA);

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
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // ============================================================
  // TIME
  // ============================================================

  Future<void> selectTime() async {
    final time = await showTimePicker(
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

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  // ============================================================
  // CONFIRM BOOKING
  // ============================================================

  Future<void> confirmBooking() async {
    if (selectedDate == null ||
        selectedTime == null ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date, time and enter your address'),
        ),
      );

      return;
    }

    setState(() {
      booking = true;
    });

    // Temporary booking simulation.
    // Later we can connect your FastAPI booking API here.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      booking = false;
    });

    showDialog(
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

              Text(
                'Your booking with '
                '${widget.provider["name"]} '
                'has been confirmed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8DA1BD),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
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
            // SMALL PROVIDER CARD
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
                  // Avatar
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

                  // Provider information
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

                  // Price
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
                // DATE
                Expanded(
                  child: _buildSelectionField(
                    icon: Icons.calendar_month_rounded,
                    label: 'DATE',
                    value: formatDate(),
                    onTap: selectDate,
                  ),
                ),

                const SizedBox(width: 10),

                // TIME
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
