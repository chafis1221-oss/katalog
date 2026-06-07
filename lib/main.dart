import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katalog/providers/product_provider.dart';
import 'package:katalog/providers/cart_provider.dart';
import 'package:katalog/screens/home_screen.dart';
import 'package:katalog/screens/cart_screen.dart';
import 'package:katalog/screens/kasir_screen.dart';
import 'package:katalog/screens/calculator_screen.dart';
import 'package:katalog/screens/product_form_screen.dart';

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
        // ✅ Tampilkan error di layar, jangan hitam polos
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Container(
              color: Colors.yellow,
              child: Center(
                child: Text(
                  'Error: ${details.exception}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          };
          return child ?? const SizedBox();
        },
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
    const ProductFormScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
        ],
      ),
    );
  }
}
