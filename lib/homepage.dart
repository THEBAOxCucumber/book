import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';
import 'search.dart';
import 'authenticationService.dart';
import 'drawer.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const MyHomePage({super.key, required this.onToggleTheme});

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(onToggleTheme: onToggleTheme);
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> booktell = Firebase.initializeApp();
  final VoidCallback onToggleTheme;
  _MyHomePageState({required this.onToggleTheme});

  

  /// แสดงรายละเอียดหนังสือใน Dialog
  void _showBookDetail(BuildContext context, QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(doc['name']),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(doc['image'], height: 300, fit: BoxFit.cover),
                  const SizedBox(height: 10),
                  Text('ราคา: ${doc['price']} THB'),
                  Text('ผู้เขียน: ${doc['author']}'),
                  Text('สำนักพิมพ์: ${doc['publisher']}'),
                  const SizedBox(height: 10),
                  Text(doc['review']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: booktell,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ Firebase')),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const Image(
                image: AssetImage("images/Read and tell bw.png"),
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
                },
              ),
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                ),
                onPressed: widget.onToggleTheme,
              ),
              
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('booktells').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching data'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No books found'));
              }

              final docs = snapshot.data!.docs;

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 12,
                padding: const EdgeInsets.all(12),
                children:
                    docs.map((doc) {
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showBookDetail(context, doc),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.asset(
                                    doc["image"]!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  doc["name"]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          drawer: MyDrawer(onToggleTheme: onToggleTheme)
          
        );
      },
    );
  }
}
