import 'package:flutter/material.dart';
// import 'package:project_book/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'homepage.dart';
// import 'drawer.dart';
// import 'credit.dart';
import 'package:provider/provider.dart';
import 'cart.dart';
// import 'favoriteservice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final cartProvider = CartProvider();
  await cartProvider.loadCart(); // ✅ โหลดก่อน runApp
  

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final loggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  // final VoidCallback onToggleTheme;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cartProvider),
      ],
      child: MyApp(isDarkMode: isDarkMode, isLoggedIn: loggedIn, /*onToggleTheme: onToggleTheme,*/)));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;
  //final VoidCallback onToggleTheme;
  const MyApp({super.key, required this.isDarkMode, required this.isLoggedIn, /*required this.onToggleTheme*/});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  // late bool _isLoggedIn;
  // int _selectedIndex = 0;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });

  //   switch (index) {
  //     case 0:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => MyHomePage(onToggleTheme: widget.onToggleTheme,)),
  //       );
  //       break;
  //     case 1:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => CreditPage()),
  //       );
  //       break;
  //     case 2:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => BookTellPage()),
  //       );
  //       break;
  //   }
  // }
  //  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     drawer: MyDrawer(
  //       onToggleTheme: () {}, 
  //       selectedIndex: _selectedIndex,
  //       onItemTapped: _onItemTapped,
  //     ),
  //     body: Center(child: Text("Page $_selectedIndex")),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    final focusNode = FocusNode();
    // _isLoggedIn = widget.isLoggedIn;
    WidgetsBinding.instance.addPostFrameCallback((_) {
  focusNode.requestFocus();
});
  }

  void _toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'แอปสั่งหนังสือ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF103F91),
        useMaterial3: true,
        scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF28292e) : Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF103F91),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF103F91),
          ),
        ),
        fontFamily: 'Prompt',
      ),
      home: MyHomePage(onToggleTheme: _toggleTheme)
      
      // _isLoggedIn
      //     ? MyHomePage(onToggleTheme: _toggleTheme)
      //     : LoginScreen(onToggleTheme: _toggleTheme)
      
      //LoginScreen(onToggleTheme: _toggleTheme), // ---------- อันนี้คือหน้าแรกที่เปิดมา ถ้าอยากให้เปิดหน้าอื่นก็เปลี่ยนตรงนี้ ---------- //
    );
  }
}

/// ----------------------
/// หน้าแรก (Landing Page)
/// ----------------------