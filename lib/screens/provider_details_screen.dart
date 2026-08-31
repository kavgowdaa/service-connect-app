import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Map provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final String name = provider['name']?.toString() ?? 'Provider';
    final String service = provider['service']?.toString() ?? 'Service';
    final String description =
        provider['description']?.toString() ?? 'Professional service provider';

    final double rating = (provider['rating'] as num?)?.toDouble() ?? 0.0;

    final double price = (provider['price'] as num?)?.toDouble() ?? 0.0;

    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: const Color(0xFF071A33),

      appBar: AppBar(
        backgroundColor: const Color(0xFF071A33),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Provider Details',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                children: [
                  // =====================================================
                  // PROFILE
                  // =====================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102846),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF294566)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF216BFF), Color(0xFF604DE4)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF35D07F),
                              size: 20,
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          service.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF7E96B7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _info(
                              Icons.star_rounded,
                              rating.toStringAsFixed(1),
                              'Rating',
                              const Color(0xFFFFC857),
                            ),
                            _info(
                              Icons.work_outline_rounded,
                              '120+',
                              'Jobs',
                              const Color(0xFF4B8BFF),
                            ),
                            _info(
                              Icons.verified_rounded,
                              'Verified',
                              'Status',
                              const Color(0xFF35D07F),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // LOCATION
                  // =====================================================
                  _sectionCard(
                    title: 'Location',
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: const Color(0xFF172F4D),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.map_rounded,
                              size: 55,
                              color: Color(0xFF4A6587),
                            ),
                          ),

                          Positioned(
                            left: 14,
                            bottom: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF102846),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF294566),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFF4B8BFF),
                                    size: 19,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Mangaluru • Available nearby',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // ABOUT
                  // =====================================================
                  _sectionCard(
                    title: 'About',
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF8DA1BD),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // SERVICE INFORMATION
                  // =====================================================
                  _sectionCard(
                    title: 'Service Information',
                    child: Column(
                      children: [
                        _detailRow(Icons.category_outlined, 'Service', service),
                        const SizedBox(height: 14),
                        _detailRow(
                          Icons.schedule_rounded,
                          'Availability',
                          'Available today',
                        ),
                        const SizedBox(height: 14),
                        _detailRow(
                          Icons.location_on_outlined,
                          'Service Area',
                          'Mangaluru',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // BOTTOM BOOKING BAR
          // ============================================================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0C223D),
              border: const Border(top: BorderSide(color: Color(0xFF294566))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Starting from',
                      style: TextStyle(color: Color(0xFF7189AA), fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'per hour',
                      style: TextStyle(color: Color(0xFF7189AA), fontSize: 10),
                    ),
                  ],
                ),

                const Spacer(),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(provider: provider),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF216BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Book Now →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
  // INFO ITEM
  // ============================================================

  Widget _info(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 23),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF7189AA), fontSize: 10),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF102846),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFF294566)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF172F4D),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4B8BFF), size: 19),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Color(0xFF7189AA), fontSize: 12),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
