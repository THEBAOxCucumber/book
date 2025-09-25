import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart.dart';

import 'order.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  User? get user => FirebaseAuth.instance.currentUser;

  Stream<List<OrderHistoryModel>> getOrders() {
    return FirebaseFirestore.instance
        .collection("order_history")
        .where("email", isEqualTo: user!.email)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final items = (data['items'] as List<dynamic>? ?? []).map((item) {
              return CartItem(
                orderid: doc.id,
                name: item['name'] ?? '',
                image: item['image'],
                price: (item['price'] as num?)?.toDouble() ?? 0.0,
                quantity: item['quantity'] ?? 1,
              );
            }).toList();

            return OrderHistoryModel(
              orderId: doc.id,
              email: data['email'] ?? '-',
              deliveredAt: (data['deliveredAt'] as Timestamp?)
                      ?.toDate()
                      .toString() ??
                  '-',
              items: items,
              total: (data['total'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: StreamBuilder<List<OrderHistoryModel>>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading order history"));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text("No order history yet"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              // รวมราคารวมของออเดอร์นี้
              final double totalPrice = order.items.fold<double>(
                0,
                (sum, item) => sum + (item.price * item.quantity),
              );

              return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: ExpansionTile(
    // ✅ แสดงภาพเล่มแรกเป็น preview
  

    title: Text("Order ${order.deliveredAt}"),
    subtitle: Text("รวม ${order.items.length} เล่ม"),

    children: [
      // ✅ แสดงทุกรายการพร้อมรูป
      ...order.items.map(
        (item) => ListTile(
          leading: item.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item.image,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.book, size: 40, color: Colors.grey),
          title: Text(item.name),
          subtitle: Text(
            '฿${(item.price * item.quantity).toStringAsFixed(2)} x ${item.quantity}',
          ),
        ),
      ).toList(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Total: ฿${totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
);

            },
          );
        },
      ),
    );
  }
}

class OrderHistoryModel {
  final String orderId;
  final String email;
  final String deliveredAt;
  final double total;
  final List<CartItem> items;

  OrderHistoryModel({
    required this.orderId,
    required this.email,
    required this.total,
    required this.deliveredAt,
    required this.items,
  });
}
