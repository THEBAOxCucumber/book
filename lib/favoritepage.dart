import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  // Get current user
  User? get user => FirebaseAuth.instance.currentUser;

  // Stream all favorite books (by ID & title)
  Stream<List<Book>> getFavorites() {
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("favorites")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Book(
                id: doc.id,
                title: doc["title"] ?? "Untitled",
              );
            }).toList());
  }

  // Toggle add/remove favorite
  Future<void> toggleFavorite(Book book) async {
    if (user == null) return;

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
        "title": book.title,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
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
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(book.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => toggleFavorite(book),
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

