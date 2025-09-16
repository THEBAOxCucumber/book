import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
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
        scaffoldBackgroundColor:
            _isDarkMode ? Colors.black : Colors.white,
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
      home: HomePage(onToggleTheme: _toggleTheme), //main
    );
  }
}

/// ----------------------
/// หน้าแรก (Landing Page)
/// ----------------------
class HomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const HomePage({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 60), // เว้นพื้นที่ด้านบน
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "images/Read and tell bwpng.png",
                    width: 300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Read and tell",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF103F91),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "ยินดีต้อนรับเข้าสู่Application สำหรับการรีวิวหนังสือ\n"
                    "ขอขอบคุณแรงบันดาลใจสำคัญจาก #เล่าหนังสือ\n"
                    "โดย คุณกอล์ฟ กิตติพัทธ์ ชลารักษ์\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MyHomePage(onToggleTheme: onToggleTheme),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                      backgroundColor: const Color(0xFF103F91),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "เริ่มสั่งซื้อ",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 80),
                  const SizedBox(height: 10),
                  const TextButton(
                    onPressed: null,
                    child: Text(
                      "This project is part of the 02739342 course\n"
                      "Application Development for Mobile Devices\n"
                      "นางสาวพิริยาภรณ์ แย้มสำรวล 6621601123\n"
                      "นายพีรพล ศิริวัฒน์ 6621601131\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
