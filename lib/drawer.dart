import 'package:flutter/material.dart';
import 'package:project_book/CRUDnav.dart';
import 'package:project_book/favoritepage.dart';
import 'package:project_book/homepage.dart';
import 'authenticationService.dart';
import 'loginpage.dart';
import 'credit.dart';
import 'booktell.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

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
  final _isVisible = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

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
          SizedBox(height: 2),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(email ?? " "),
          ),
          // 👇 Place all your ListTiles here inside the drawer
          Divider(
            height: 20, // Total height of the divider, including padding
            thickness: 1, // Thickness of the line itself
            indent: 16, // Space from the leading edge to the start of the line
            endIndent:
                16, // Space from the trailing edge to the end of the line
            color: Colors.grey, // Color of the divider line
          ),
          ListTile(
            selected: _selectedIndex == 0,
            leading: const Icon(Icons.home),
            title: const Text('หน้าแรก'),
            onTap: () {
              _onItemTapped(0);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MyHomePage(onToggleTheme: widget.onToggleTheme),
                ),
                (route) => false,
              );
            },
          ),
          AuthenticationService().getEmail() == "Guest"
              ? const SizedBox.shrink()
              : ListTile(
            enabled: email != "Guest",
            selected: _selectedIndex == 1,
            leading: const Icon(Icons.book),
            title: const Text('หนังสือของฉัน'),
            onTap: () {
              _onItemTapped(1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FavoritePage(),
                ),
              );
            },
          ),
          ListTile(
            selected: _selectedIndex == 2,
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

          // ----- เตือน: แก้เงื่อนไขว่าจะแสดงตอน login email อะไร
          // ListTile(
          //   selected: _selectedIndex == 3,
            // leading: const Icon(Icons.add),
            // title: const Text('เพิ่ม/แก้ไข/ลบหนังสือ'),
            // onTap: () {
            //   _onItemTapped(3);
            //   print(_selectedIndex);
            //   Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => Crudnav(onToggleTheme: widget.onToggleTheme),
            //     ),
            //     (route) => false,
            //   );
            // },
          // ),
          AuthenticationService().getEmail() == "Guest"
              ? const SizedBox.shrink()
              : ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'ออกจากระบบ',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AuthenticationService().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              MyHomePage(onToggleTheme: widget.onToggleTheme),
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
