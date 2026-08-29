import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

// ======================================================
// SERVICE PROVIDER MODEL
// ======================================================

class ServiceProvider {
  String name;
  String service;
  double price;

  ServiceProvider(this.name, this.service, this.price);

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      json['name'],
      json['service'],
      (json['price'] as num).toDouble(),
    );
  }
}
// ======================================================
// BOOKING MODEL
// ======================================================

class Booking {
  String providerName;
  String service;
  double price;

  Booking(
    this.providerName,
    this.service,
    this.price,
  );
}

List<Booking> bookings = [];


// ======================================================
// MAIN APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServiceConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ======================================================
// SPLASH SCREEN
// ======================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.lightBlue,
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman,
              size: 90,
              color: Colors.white,
            ),

            SizedBox(height: 20),

            Text(
              'ServiceConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Find trusted services near you',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 40),

            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// LOGIN SCREEN
// ======================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email and password',
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.handyman,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login to continue to ServiceConnect',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REGISTER SCREEN
// ======================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  void register() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword =
        confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registration successful',
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.person_add,
                size: 70,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: register,
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HOME SCREEN
// ======================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<ServiceProvider> searchResults = [];

  final List<String> services = [
    'plumbing',
    'electrical',
    'cleaning',
    'carpentry',
  ];

  final List<double> prices = [
    500,
    700,
    400,
    800,
  ];

  Future<List<ServiceProvider>> fetchProviders() async {
    final response = await http.get(
      Uri.parse(
        'https://jsonplaceholder.typicode.com/users',
      ),
    );
    

    print('API Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<ServiceProvider> apiProviders = [];

      for (int index = 0;
          index < data.length;
          index++) {
        var item = data[index];

        ServiceProvider provider =
            ServiceProvider.fromJson({
          'name': item['name'],
          'service': services[index % 4],
          'price': prices[index % 4],
        });

        apiProviders.add(provider);
      }

      return apiProviders;
    }

    return [];
  }
  Future<void> searchService(
    String service,
  ) async {
    searchController.text = service;

    final apiProviders =
        await fetchProviders();

    List<ServiceProvider> foundProviders = [];

    for (ServiceProvider provider
        in apiProviders) {
      if (provider.service.toLowerCase() ==
          service.toLowerCase()) {
        foundProviders.add(provider);
      }
    }

    setState(() {
      searchResults = foundProviders;
    });
  }

  Future<void> searchFromText() async {
    String service =
        searchController.text.trim().toLowerCase();

    if (service.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final apiProviders =
        await fetchProviders();

    List<ServiceProvider> foundProviders = [];

    for (ServiceProvider provider
        in apiProviders) {
      if (provider.service.toLowerCase() ==
          service) {
        foundProviders.add(provider);
      }
    }

    setState(() {
      searchResults = foundProviders;
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ServiceConnect',
        ),
      actions: [
  IconButton(
    icon: const Icon(Icons.book_online),
    tooltip: 'My Bookings',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const MyBookingsScreen(),
        ),
      );
    },
  ),

  IconButton(
    icon: const Icon(Icons.logout),
    tooltip: 'Logout',
    onPressed: logout,
  ),
],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Find trusted services near you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: searchController,
              decoration:
                  const InputDecoration(
                hintText:
                    'Search for a service',
                prefixIcon:
                    Icon(Icons.search),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: searchFromText,
                child: const Text(
                  'Search',
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView(
                children: [
                  if (searchResults.isNotEmpty)
                    ...searchResults.map(
                      (provider) {
                        return Card(
                          child: ListTile(
                            leading:
                                const CircleAvatar(
                              child: Icon(
                                Icons.person,
                              ),
                            ),
                            title: Text(
                              provider.name,
                            ),
                            subtitle: Text(
                              provider.service,
                            ),
                            trailing: Text(
                              '₹${provider.price}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ProviderDetailsScreen(
                                    provider:
                                        provider,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                  if (searchResults.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        'Select a popular service to find providers.',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  const Text(
                    'Popular Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ServiceCard(
                          icon:
                              Icons.plumbing,
                          title:
                              'Plumbing',
                          onTap: () {
                            searchService(
                              'plumbing',
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: ServiceCard(
                          icon: Icons
                              .electrical_services,
                          title:
                              'Electrical',
                          onTap: () {
                            searchService(
                              'electrical',
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ServiceCard(
                          icon: Icons
                              .cleaning_services,
                          title:
                              'Cleaning',
                          onTap: () {
                            searchService(
                              'cleaning',
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: ServiceCard(
                          icon:
                              Icons.handyman,
                          title:
                              'Carpentry',
                          onTap: () {
                            searchService(
                              'carpentry',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SERVICE CARD
// ======================================================

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),

              const SizedBox(height: 8),

              Text(
                title,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ======================================================
// MY BOOKINGS SCREEN
// ======================================================
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState
    extends State<MyBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),

      body: bookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Card(
  child: ListTile(
    leading: const CircleAvatar(
      child: Icon(Icons.check),
    ),

    title: Text(
      booking.providerName,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    subtitle: Text(
      '${booking.service}\n₹${booking.price}',
    ),

    isThreeLine: true,

    trailing: IconButton(
      icon: const Icon(
        Icons.cancel,
        color: Colors.red,
      ),
      tooltip: 'Cancel Booking',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Cancel Booking?'),
              content: Text(
                'Are you sure you want to cancel your booking with ${booking.providerName}?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      bookings.removeAt(index);
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Booking cancelled successfully',
                        ),
                      ),
                    );
                  },
                  child: const Text('Yes, Cancel'),
                ),
              ],
            );
          },
        );
      },
    ),
  ),
);
          
              },
            ),
    );
  }
}

// ======================================================
// PROVIDER DETAILS SCREEN
// ======================================================

// ======================================================
// PROVIDER DETAILS SCREEN
// ======================================================

class ProviderDetailsScreen extends StatefulWidget {
  final ServiceProvider provider;

  const ProviderDetailsScreen({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderDetailsScreen> createState() =>
      _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState
    extends State<ProviderDetailsScreen> {

  // ======================================================
  // BOOK SERVICE
  // ======================================================

  Future<void> bookService() async {
    // Prevent duplicate booking
    final alreadyBooked = bookings.any(
      (booking) =>
          booking.providerName == widget.provider.name &&
          booking.service == widget.provider.service,
    );

    if (alreadyBooked) {
      throw Exception('Already booked');
    }

    final response = await http.post(
      Uri.parse(
        'https://jsonplaceholder.typicode.com/posts',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'providerName': widget.provider.name,
        'service': widget.provider.service,
        'price': widget.provider.price,
      }),
    );

    print(
      'Booking response: ${response.statusCode}',
    );

    if (response.statusCode == 201) {
      bookings.add(
        Booking(
          widget.provider.name,
          widget.provider.service,
          widget.provider.price,
        ),
      );
    } else {
      throw Exception('Booking failed');
    }
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Provider Details',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // Provider Icon
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Provider Name
            Text(
              widget.provider.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Service
            Text(
              'Service: ${widget.provider.service}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            // Price
            Text(
              'Price: ₹${widget.provider.price}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await bookService();

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking request sent to '
                          '${widget.provider.name}',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().contains(
                                  'Already booked')
                              ? 'You have already booked this service.'
                              : 'Booking failed. Please try again.',
                        ),
                      ),
                    );
                  }
                },

                child: const Text(
                  'Book Service',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}