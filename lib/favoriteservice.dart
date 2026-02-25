import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteIcon extends StatefulWidget {
  final String bookId;     // id หนังสือ
  final String name;      // ชื่อหนังสือ
  final int price;    // ราคาหนังสือ
  final String image;  // รูปหนังสือ (ถ้ามี)

  const FavoriteIcon({
    super.key,
    required this.bookId,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  State<FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  /// ตรวจสอบว่าหนังสือนี้ถูกกดหัวใจไปแล้วหรือยัง
  Future<void> _checkFavorite() async {
  if (user == null) return;

  final docRef = FirebaseFirestore.instance
      .collection("favorites")
      .doc('${user!.email}_${widget.bookId}');

  final snapshot = await docRef.get();
  setState(() {
    _isFavorite = snapshot.exists;
  });
}


  /// กดหัวใจ -> toggle favorite
  Future<void> _toggleFavorite() async {
  if (user == null) return;

  final docRef = FirebaseFirestore.instance
      .collection("favorites")
      .doc('${user!.email}_${widget.bookId}');

  final snapshot = await docRef.get();

  if (snapshot.exists) {
    await docRef.delete();
    setState(() {
      _isFavorite = false;
    });
  } else {
    await docRef.set({
      "bookId": widget.bookId,
      "name": widget.name,
      "email": user!.email, // เฉพาะ user
      "price": widget.price,
      "image": widget.image,
      "createdAt": FieldValue.serverTimestamp(),
    });
    setState(() {
      _isFavorite = true;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
