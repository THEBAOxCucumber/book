import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CartItem {
  final String orderid;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.orderid,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
    'orderid': orderid,
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}




class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _items.map((key, item) => MapEntry(
      key,
      {
        'orderid': item.orderid,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      },
    ));
    await prefs.setString('cart_items', jsonEncode(cartData));
  }

    Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_items');
    if (data == null) return;

    final decoded = jsonDecode(data) as Map<String, dynamic>;
    _items.clear();
    decoded.forEach((key, value) {
      _items[key] = CartItem(
        orderid: value['orderid'],
        name: value['name'],
        price: (value['price'] as num).toDouble(),
        quantity: value['quantity'],
      );
    });
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          orderid: existing.orderid,
          name: existing.name,
          price: existing.price,
          // image: existing.image,
          quantity: existing.quantity + 1,
        ),
      );
      _saveCart();
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          orderid: existing.orderid,
          name: existing.name,
          price: existing.price,
          // image: existing.image,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    _saveCart();
    notifyListeners();
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          orderid: existing.orderid,
          name: existing.name,
          price: existing.price,
          // image: existing.image,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          orderid: productId,
          name: title,
          price: price,
          // image: image,
          quantity: 1,
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _saveCart();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _placeOrder(
  BuildContext context,
  Map<String, CartItem> items,
  double total,
) async {
  final user = FirebaseAuth.instance.currentUser; // ดึงผู้ใช้ปัจจุบัน
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please log in to place an order")),
    );
    return;
  }

  final orderCollection = FirebaseFirestore.instance.collection('orders');

  try {
    await orderCollection.add({
      'email': user.email, // <-- เพิ่ม email ของผู้ใช้
      'total': total,
      'date': Timestamp.now(),
      'items': items.values
          .map(
            (item) => {
              'orderid': item.orderid,
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
            },
          )
          .toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to place order: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          final cartItems = cart.items.values.toList();

          return Column(
            children: [
              Expanded(
                child:
                    cartItems.isEmpty
                        ? const Center(child: Text("Your cart is empty"))
                        : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (ctx, i) {
                            final item = cartItems[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text(
    "฿${(item.price * item.quantity).toStringAsFixed(2)}",
  ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      onPressed:
                                          () => cart.decreaseQuantity(
                                            item.orderid,
                                          ),
                                    ),
                                    Text(
                                      "${item.quantity}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      onPressed:
                                          () => cart.increaseQuantity(
                                            item.orderid,
                                          ),
                                    ),
                                    // IconButton(
                                    //   icon: const Icon(Icons.delete),
                                    //   onPressed: () =>
                                    //       cart.removeItem(item.id),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   "Total: ฿${cart.totalAmount.toStringAsFixed(2)}",
                    //   style: const TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF103F91),
                          foregroundColor: Colors.white,
                        ),
                        onPressed:
                            cart.items.isEmpty
                                ? null
                                : () async {
                                  // แสดง dialog ยืนยันการสั่งซื้อ

                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('สั่งซื้อ'),
                                          content: const Text(
                                            'คุณต้องการสั่งซื้อหนังสือ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('ยกเลิก'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                  );

                                  // ถ้ากด Yes ให้บันทึก order และเคลียร์ตะกร้า
                                  if (confirm == true) {
                                    await _placeOrder(
                                      context,
                                      cart.items,
                                      cart.totalAmount,
                                    );
                                    cart.clear();
                                  }
                                },
                        child: const Text('สั่งซื้อ'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
