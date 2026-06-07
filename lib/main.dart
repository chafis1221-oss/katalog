import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katalog/providers/product_provider.dart';
import 'package:katalog/providers/cart_provider.dart';
import 'package:katalog/screens/home_screen.dart';
import 'package:katalog/screens/cart_screen.dart';
import 'package:katalog/screens/kasir_screen.dart';
import 'package:katalog/screens/calculator_screen.dart';
import 'package:katalog/screens/product_form_screen.dart';
import 'package:katalog/screens/status_screen.dart';

void main() {
  runApp(const WarungDigitalApp());
}

class WarungDigitalApp extends StatelessWidget {
  const WarungDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Warung Digital',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const KasirScreen(),
    const CalculatorScreen(),
    const StatusScreen(),
  ];

  void _onTabSelected(int index) {
    // Tab "Tambah" (index 4) dibuka sebagai route push
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductFormScreen()),
      ).then((result) {
        setState(() => _currentIndex = 0);
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
        context.read<ProductProvider>().fetchAllProducts();
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store),
            selectedIcon: Icon(Icons.store, color: Colors.teal),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.shopping_cart)),
            selectedIcon: Badge(child: Icon(Icons.shopping_cart, color: Colors.teal)),
            label: 'Keranjang',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            selectedIcon: Icon(Icons.point_of_sale, color: Colors.teal),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            selectedIcon: Icon(Icons.calculate, color: Colors.teal),
            label: 'Kalkulator',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box),
            selectedIcon: Icon(Icons.add_box, color: Colors.teal),
            label: 'Tambah',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart),
            selectedIcon: Icon(Icons.monitor_heart, color: Colors.teal),
            label: 'Status',
          ),
        ],
      ),
    );
  }
}