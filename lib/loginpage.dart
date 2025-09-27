import 'package:flutter/material.dart';
import 'authenticationService.dart';
// import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final focusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Future<void> _login() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isLoggedIn', true);
  // }

  Future<bool> _getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('isDarkMode'));
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> _handleLogin(username, password) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = await AuthenticationService().login(username, password);

      if (success) {
        // _showMessage('เข้าสู่ระบบสำเร็จ');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => MyHomePage(onToggleTheme: widget.onToggleTheme),
          ),
        );
      } else {
        _showMessage('อีเมลหรือรหัสผ่านไม่ถูกต้อง', isError: true);
      }
    } catch (e) {
      // แสดงเฉพาะข้อความภาษาไทยที่เข้าใจง่าย
      String errorMessage = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
      if (e.toString().contains('ไม่พบผู้ใช้')) {
        errorMessage = 'ไม่พบบัญชีผู้ใช้นี้';
      } else if (e.toString().contains('รหัสผ่าน')) {
        errorMessage = 'รหัสผ่านไม่ถูกต้อง';
      } else if (e.toString().contains('network')) {
        errorMessage = 'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      }
      _showMessage(errorMessage, isError: true);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        backgroundColor: Color(0xFF103F91),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 32),

                // Logo
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white),
                  child: const Image(
                    image: AssetImage("images/Read and tell bwpng.png"),
                    width: 500,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'ยินดีต้อนรับ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'สู่ร้านขายหนังสือ Read and Tell',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 32),

                // ช่องกรอกอีเมล
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  focusNode: focusNode,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!value.contains('@')) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),

                // ช่องกรอกรหัสผ่าน
                TextFormField(
                  focusNode: focusNode,
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 24),

                // ปุ่มเข้าสู่ระบบ
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _handleLogin(email, password),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF103F91),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // เส้นแบ่ง
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('หรือ', style: TextStyle()),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),

                const SizedBox(height: 24),

                // ปุ่มไปหน้าสมัครสมาชิก
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FutureBuilder<bool>(
                    future: _getTheme(),
                    builder: (context, snapshot) {
                      final isDarkMode = snapshot.data ?? false;
                      return OutlinedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
                                    ),
                                  );
                                },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDarkMode ? Colors.white : Color(0xFF103F91),
                          side: BorderSide(
                            color:
                                isDarkMode ? Colors.white : Color(0xFF103F91),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ลิงก์ลืมรหัสผ่าน
                TextButton(
                  onPressed: () {
                    _showResetPasswordDialog();
                  },
                  child: FutureBuilder<bool>(
                    future: _getTheme(),
                    builder: (context, snapshot) {
                      final isDarkMode = snapshot.data ?? false;
                      return Text(
                        'ลืมรหัสผ่าน?',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Color(0xFF103F91),
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    String email = '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('รีเซ็ตรหัสผ่าน'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('กรอกอีเมลเพื่อรับลิงก์รีเซ็ตรหัสผ่าน'),
                SizedBox(height: 16),
                TextFormField(
                  focusNode: focusNode,
                  onChanged: (value) {
                    email = value;
                  },
                  controller: resetEmailController,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (resetEmailController.text.isNotEmpty) {
                    try {
                      await AuthenticationService().resetpassword(email);
                      Navigator.pop(context);
                      _showMessage('ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว');
                    } catch (e) {
                      _showMessage('ไม่สามารถส่งอีเมลได้', isError: true);
                    }
                  }
                },
                child: Text('ส่ง'),
              ),
            ],
          ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
