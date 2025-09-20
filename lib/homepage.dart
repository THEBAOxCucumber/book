import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';
import 'search.dart';
import 'authenticationService.dart';
import 'drawer.dart';
import 'cart.dart';
import 'package:provider/provider.dart';
import 'book.dart';
import 'favoriteservice.dart';

final List<Book> books = [
  Book(id: "1", title: "Book A"),
  Book(id: "2", title: "Book B"),
  Book(id: "3", title: "Book C"),
];

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
  //final favoriteService = FavoriteService();
  _MyHomePageState({required this.onToggleTheme});

  bool _canShowButton = true;
  void hideWidget() {
    setState(() {
      _canShowButton = !_canShowButton;
    });
  }

  Future<void> toggleFavorite(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("favorites")
        .doc(book.id);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        "itemId": book.id,
        "title": book.title,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchPage()),
                  );
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
              AuthenticationService().getEmail() != "Guest"
                  ? IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CartPage()),
                      );
                    },
                  )
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFffd342,
                      ), // button background color
                      foregroundColor: Colors.black, // text color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // rounded corners
                      ),
                    ),
                    child: const Text('Login'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  LoginScreen(onToggleTheme: onToggleTheme),
                        ),
                      );
                    },
                  ),
              SizedBox(width: 10),
              //   ElevatedButton(
              //   child: Text("Login"),
              //   onPressed: () {
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginScreen(onToggleTheme: onToggleTheme,)),
              //       (route) => false,
              //     );
              //   },
              // ),
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
                childAspectRatio: 0.7, // 🔑 lower than 1.0 makes card taller
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
                                  child: Image.network(
                                    doc["image"] ?? "", // ✅ safer
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 80,
                                            ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  doc["name"] ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // ✅ Show Add to Cart only for logged-in users
                              AuthenticationService().getEmail() == "Guest"
                                  ? const SizedBox.shrink()
                                  : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFffd342,
                                            ),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Add to cart'),
                                          onPressed: () {
                                            Provider.of<CartProvider>(
                                              context,
                                              listen: false,
                                            ).addItem(
                                              doc.id,
                                              doc["name"] ?? "Unknown",
                                              doc["price"] ?? "0",
                                            );
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: FavoriteIcon(),
                                        onPressed: () {
                                          toggleFavorite(
                                            Book(
                                              id: doc.id,
                                              title: doc["name"] ?? "Unknown",
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          drawer: MyDrawer(onToggleTheme: onToggleTheme),
        );
      },
    );
  }
}
