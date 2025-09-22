import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  User? get user => FirebaseAuth.instance.currentUser;

  // ดึงข้อมูล favorites ทั้งหมดของ user
  Stream<List<Book>> getFavorites() {
    if (user == null) return Stream.empty();

    return FirebaseFirestore.instance
        .collection("favorites")
        .where("email", isEqualTo: user!.email) // เอาเฉพาะของ user นี้
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Book.fromFirestore(doc.id, doc.data()))
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: StreamBuilder<List<Book>>(
        stream: getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading favorites"));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(child: Text("No favorites yet"));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final book = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(book.name.isNotEmpty ? book.name : '-'),
                  leading:
                      book.image != null
                          ? Image.network(
                            book.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.book, size: 50),
                  subtitle: Text(
                    'ราคา: ${book.price?.toStringAsFixed(2) ?? '-'} THB',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      // ยืนยันก่อนลบ
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('ลบรายการโปรด'),
                              content: const Text(
                                'คุณต้องการลบหนังสือเล่มนี้ออกจากรายการโปรดหรือไม่?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('ลบ'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('favorites')
                            .doc(book.id) // ใช้ id ของเอกสาร favorites
                            .delete();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
