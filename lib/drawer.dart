import 'package:flutter/material.dart';
import 'authenticationService.dart';
import 'loginpage.dart';
import 'credit.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key, required this.title, required this.onToggleTheme});
  final VoidCallback onToggleTheme;
  final String title;

  @override
  State<MyDrawer> createState() => _MyDrawer();
}

class _MyDrawer extends State<MyDrawer> {
  int _selectedIndex = 0;
  final String? email = AuthenticationService().getEmail();
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // const DrawerHeader(
          //   decoration: BoxDecoration(color: Colors.blue),
          //   child: ListTile(
          //     title: Text(
          //       'เมนู',
          //       style: TextStyle(color: Colors.white, fontSize: 24),
          //     ),
          //     subtitle: Text(''),
          //   ),
          // ),

          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(AuthenticationService().getEmail() ?? ''),
          ),
          // 👇 Place all your ListTiles here inside the drawer
          Divider(
            height: 20, // Total height of the divider, including padding
            thickness: 1, // Thickness of the line itself
            indent: 16, // Space from the leading edge to the start of the line
            endIndent: 16, // Space from the trailing edge to the end of the line
            color: Colors.grey, // Color of the divider line
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('หน้าแรก'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('หนังสือของฉัน'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/mybooks');
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('เหล่าผู้จัดทำ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CreditPage(onToggleTheme: widget.onToggleTheme),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              AuthenticationService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => LoginScreen(onToggleTheme: widget.onToggleTheme),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
