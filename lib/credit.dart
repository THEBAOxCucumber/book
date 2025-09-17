import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

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
                  Image.asset("images/Read and tell bwpng.png", width: 300),
                  const SizedBox(height: 20),
                  const Text(
                    "Read and Tell",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF103F91),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "ยินดีต้อนรับเข้าสู่Application สำหรับการรีวิวหนังสือ\n"
                    "ขอขอบคุณแรงบันดาลใจสำคัญจาก #เล่าหนังสือ\n"
                    "โดย คุณกอล์ฟ กิตติพัทธ์ ชลารักษ์\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors
                                  .white // Dark mode
                              : Colors.black, // Light mode
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => MyHomePage(onToggleTheme: onToggleTheme),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      backgroundColor: const Color(0xFF103F91),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "เริ่มสั่งซื้อ",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 80),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      "This project is part of the 02739342 course\n"
                      "Application Development for Mobile Devices\n"
                      "นางสาวพิริยาภรณ์ แย้มสำรวล 6621601123\n"
                      "นายพีรพล ศิริวัฒน์ 6621601131\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white // Dark mode
                            : Colors.black, // Light mode
                      ),
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
