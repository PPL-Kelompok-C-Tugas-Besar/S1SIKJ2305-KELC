import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymbro Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Very dark grey/black background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4500), // Neon Orange accent color
          surface: Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      home: const ShopPage(),
    );
  }
}

// Sample data to make it look professional
final List<Map<String, String>> products = [
  {'name': 'Optimum Whey', 'image': 'assets/whey.png', 'price': 'Rp 850.000'},
  {'name': 'Creatine Mono', 'image': 'assets/creatine.png', 'price': 'Rp 350.000'},
  {'name': 'Pre-Workout', 'image': 'assets/whey.png', 'price': 'Rp 450.000'},
  {'name': 'BCAA Plus', 'image': 'assets/creatine.png', 'price': 'Rp 300.000'},
  {'name': 'Mass Gainer', 'image': 'assets/whey.png', 'price': 'Rp 950.000'},
  {'name': 'Glutamine', 'image': 'assets/creatine.png', 'price': 'Rp 250.000'},
];

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search supplements...',
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFFFF4500)),
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Color(0xFFFF4500), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sort, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Grid View
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.72, // Taller ratio to fit images and text nicely
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              productName: product['name']!,
                              imagePath: product['image']!,
                              price: product['price']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                                child: Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: Image.asset(
                                    product['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Icon(Icons.fitness_center, color: Colors.grey.shade800, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['price']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final String productName;
  final String imagePath;
  final String price;
  
  const ProductDetailPage({super.key, required this.productName, required this.imagePath, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'SHOP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image with soft glowing shadow
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4500).withOpacity(0.08),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.fitness_center, color: Colors.grey.shade800, size: 60),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Product Name & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              
              // Sleek Description Box
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Premium quality supplement designed to help you crush your workouts and build lean muscle mass. Formulated with fast-absorbing ingredients for maximum results and incredible taste. No artificial fillers, just pure gains.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade300,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Professional Call-to-Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        side: const BorderSide(color: Color(0xFFFF4500), width: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          color: Color(0xFFFF4500),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4500),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        elevation: 8,
                        shadowColor: const Color(0xFFFF4500).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'PURCHASE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
