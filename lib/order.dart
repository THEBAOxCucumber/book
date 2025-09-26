import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart.dart';
import 'drawer.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  User? get user => FirebaseAuth.instance.currentUser;

  Stream<List<OrderModel>> getOrders() {
    return FirebaseFirestore.instance
        .collection("orders")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                final items =
                    (data['items'] as List<dynamic>? ?? []).map((item) {
                      return CartItem(
                        orderid: doc.id,
                        image: item['image'] ?? '',
                        name: item['name'] ?? '',
                        price: (item['price'] as num?)?.toDouble() ?? 0.0,
                        quantity: item['quantity'] ?? 1,
                      );
                    }).toList();

                return OrderModel(
                  orderId: doc.id,
                  email: data['email'] ?? '-',
                  items: items,
                  total: (data['total'] as num?)?.toDouble() ?? 0.0,
                );
              }).toList(),
        );
  }

  // ถ้าต้องการฟังก์ชันนี้จริง ๆ ก็เก็บไว้ได้
  Future<void> confirmDelivery(CartItem order, CartItem orderDoc) async {
    final double total = order.total;

    final orderRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(order.orderid);

    final historyRef =
        FirebaseFirestore.instance.collection("order_history").doc();

    await historyRef.set({
      "name": order.name,
      "image": order.image,
      "price": order.price,
      "quantity": order.quantity,
      "email": user?.email,
      "deliveredAt": FieldValue.serverTimestamp(),
    });

    await orderRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order")),
      body: StreamBuilder<List<OrderModel>>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading order"));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text("No order yet"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              // ✅ คำนวณราคารวม
              final double totalPrice = order.items.fold<double>(
                0,
                (sum, item) => sum + (item.price * item.quantity),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text("Order ${order.email}"),
                  subtitle: Text("รวม ${order.items.length} เล่ม"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF103F91),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("จัดส่ง"),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('ยืนยันการจัดส่ง'),
                              content: const Text(
                                'คุณต้องการจัดส่งออเดอร์นี้หรือไม่?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('ตกลง'),
                                ),
                              ],
                            ),
                      );

                      // ถ้าผู้ใช้กด "ตกลง"
                      if (confirm == true) {
                        final orderRef = FirebaseFirestore.instance
                            .collection("orders")
                            .doc(order.orderId);

                        final historyRef =
                            FirebaseFirestore.instance
                                .collection("order_history")
                                .doc();

                        await historyRef.set({
                          "email": order.email,
                          "total": totalPrice,
                          "items": order.items.map((i) => i.toMap()).toList(),
                          "deliveredAt": FieldValue.serverTimestamp(),
                        });

                        await orderRef.delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("จัดส่งสำเร็จ")),
                        );
                      }
                    },
                  ),

                  children: [
                    // ✅ รายการหนังสือพร้อมรูปแต่ละเล่ม
                    ...order.items.map(
                      (item) => ListTile(
                        leading:
                            item.image.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    item.image, // ต้องเป็น path ใน assets เช่น "images/xxx.jpg"
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Icon(
                                  Icons.book,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        title: Text(item.name),
                        subtitle: Text(
                          '฿${(item.price * item.quantity).toStringAsFixed(2)} x ${item.quantity}',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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

class OrderModel {
  final String orderId;
  final String email;
  final double total;
  final List<CartItem> items;

  OrderModel({
    required this.orderId,
    required this.email,
    required this.total,
    required this.items,
  });
}
