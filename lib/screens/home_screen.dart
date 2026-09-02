import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service_provider.dart';
import '../providers/service_providers_provider.dart';
import 'provider_details_screen.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedService = 'All';

  final List<Map<String, dynamic>> services = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Plumbing', 'icon': Icons.plumbing_rounded},
    {'name': 'Electrical', 'icon': Icons.bolt_rounded},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Carpentry', 'icon': Icons.carpenter_rounded},
  ];

  // ============================================================
  // CURRENT SERVICE
  // ============================================================

  String get currentService {
    return selectedService == 'All' ? '' : selectedService;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Riverpod automatically loads the providers when watched.
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT SERVICE
  // ============================================================

  void selectService(String service) {
    setState(() {
      selectedService = service;
      searchController.clear();
    });

    // Refresh the newly selected service.
    ref.invalidate(serviceProvidersProvider(currentService));
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void searchProviders() {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      // Return to selected service.
      ref.invalidate(serviceProvidersProvider(currentService));
      return;
    }

    /*
     * The backend /providers endpoint accepts the service as
     * a query parameter.
     *
     * Therefore search text is treated as a service/search term.
     *
     * Example:
     * plumbing
     * cleaning
     * electrical
     */
    ref.invalidate(serviceProvidersProvider(query));
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshProviders() async {
    ref.invalidate(serviceProvidersProvider(currentService));

    // Wait until the provider starts loading again.
    await ref.read(serviceProvidersProvider(currentService).future);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final providerAsync = ref.watch(serviceProvidersProvider(currentService));

    return Scaffold(
      backgroundColor: const Color(0xFF071A33),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF216BFF),
          backgroundColor: const Color(0xFF102846),
          onRefresh: refreshProviders,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ==================================================
              // HEADER
              // ==================================================
              SliverToBoxAdapter(child: _buildHeader()),

              // ==================================================
              // SEARCH
              // ==================================================
              SliverToBoxAdapter(child: _buildSearch()),

              // ==================================================
              // SERVICES
              // ==================================================
              SliverToBoxAdapter(child: _buildServices()),

              // ==================================================
              // PROVIDERS
              // ==================================================
              providerAsync.when(
                // ------------------------------------------------
                // LOADING
                // ------------------------------------------------
                loading: () {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3478F6),
                      ),
                    ),
                  );
                },

                // ------------------------------------------------
                // ERROR
                // ------------------------------------------------
                error: (error, stackTrace) {
                  debugPrint('RIVERPOD PROVIDER ERROR: $error');

                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(),
                  );
                },

                // ------------------------------------------------
                // DATA
                // ------------------------------------------------
                data: (providerList) {
                  if (providerList.isEmpty) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionTitle(0),
                        SizedBox(height: 320, child: _buildEmptyState()),
                      ]),
                    );
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      // SECTION TITLE
                      SliverToBoxAdapter(
                        child: _buildSectionTitle(providerList.length),
                      ),

                      // PROVIDER LIST
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final ServiceProvider provider =
                                providerList[index];

                            return _buildProviderCard(provider);
                          }, childCount: providerList.length),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          // LOGO
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF216BFF), Color(0xFF6C5CE7)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF216BFF).withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          // TITLE
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SERVICECONNECT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Trusted services, near you',
                  style: TextStyle(color: Color(0xFF8296B5), fontSize: 12),
                ),
              ],
            ),
          ),

          // MY BOOKINGS
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF112B4D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF284465)),
            ),
            child: IconButton(
              tooltip: 'My Bookings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                );
              },
              icon: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF102846),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFF294566)),
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,

          decoration: InputDecoration(
            hintText: 'Search plumbing, cleaning...',
            hintStyle: const TextStyle(color: Color(0xFF7186A5)),

            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF7F94B2),
            ),

            suffixIcon: IconButton(
              tooltip: 'Search',
              onPressed: searchProviders,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF4B8BFF),
              ),
            ),

            border: InputBorder.none,

            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),

          onSubmitted: (_) {
            searchProviders();
          },
        ),
      ),
    );
  }

  // ============================================================
  // SERVICES
  // ============================================================

  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 28),
      child: SizedBox(
        height: 94,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];

            final String name = service['name'] as String;

            final IconData icon = service['icon'] as IconData;

            final bool selected = selectedService == name;

            return GestureDetector(
              onTap: () {
                selectService(name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 82,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF236BFF), Color(0xFF5C55E8)],
                        )
                      : null,

                  color: selected ? null : const Color(0xFF102846),

                  borderRadius: BorderRadius.circular(17),

                  border: Border.all(
                    color: selected
                        ? const Color(0xFF3B7DFF)
                        : const Color(0xFF294566),
                  ),

                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF216BFF,
                            ).withValues(alpha: 0.20),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: selected ? Colors.white : const Color(0xFF7E96B7),
                      size: 25,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      name,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF91A4BF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Nearby Professionals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Text(
            '$count available',
            style: const TextStyle(
              color: Color(0xFF6E86A7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROVIDER CARD
  // ============================================================

  Widget _buildProviderCard(ServiceProvider provider) {
    final String name = provider.name;
    final String service = provider.service;
    final double rating = provider.rating;
    final double price = provider.price;

    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(provider: provider.toJson()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFF102846),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF294566)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Column(
          children: [
            // ==================================================
            // TOP ROW
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AVATAR
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C5CE0), Color(0xFF604DE4)],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // NAME + SERVICE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF35D07F),
                            size: 17,
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        service.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF7E96B7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF7189AA),
                            size: 14,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Mangaluru',
                            style: TextStyle(
                              color: Color(0xFF7189AA),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // RATING
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2F48),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC857),
                        size: 15,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            if (provider.description.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  provider.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8DA1BD),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),

            if (provider.description.isNotEmpty) const SizedBox(height: 15),

            // ==================================================
            // PRICE + BOOK BUTTON
            // ==================================================
            Row(
              children: [
                // PRICE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
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

                // BOOK NOW
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingScreen(provider: provider.toJson()),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF216BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      'Book Now →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: const Color(0xFF102846),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFF7189AA),
                size: 35,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load providers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7189AA), fontSize: 13),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: () {
                ref.invalidate(serviceProvidersProvider(currentService));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF216BFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: const Color(0xFF102846),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFF7189AA),
                size: 35,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No providers found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Try another service or search again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7189AA), fontSize: 13),
            ),

            const SizedBox(height: 18),

            TextButton(
              onPressed: () {
                setState(() {
                  selectedService = 'All';
                  searchController.clear();
                });

                ref.invalidate(serviceProvidersProvider(''));
              },
              child: const Text(
                'Show All Providers',
                style: TextStyle(
                  color: Color(0xFF4B8BFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
