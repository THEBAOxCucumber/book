import 'package:flutter/material.dart';
import 'homepage.dart';

class CreditPage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const CreditPage({super.key, required this.onToggleTheme});

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

                  // แสดงภาพเป็นวงกลม
                  ClipOval(
                    child: Image.asset(
                      "images/481075447_1197734011711237_3097041767860134394_n.jpg", // ใส่ path รูปที่คุณมี
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover, // ครอบให้เต็มวงกลม
                    ),
                  ),

                  const SizedBox(height: 40),
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
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors
                                    .white // Dark mode
                                : Colors.black, // Light mode
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      "images/S__62791683.jpg", // ใส่ path รูปที่คุณมี
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover, // ครอบให้เต็มวงกลม
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
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
                      "กลับไปหน้าหลัก",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
