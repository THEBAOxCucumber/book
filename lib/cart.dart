import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
  });
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

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          final cartItems = cart.items.values.toList();

          return Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(
                        child: Text("Your cart is empty"),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, i) {
                          final item = cartItems[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(
                                  "฿${item.price.toStringAsFixed(2)}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () =>
                                        cart.decreaseQuantity(item.id),
                                  ),
                                  Text(
                                    "${item.quantity}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: () =>
                                        cart.increaseQuantity(item.id),
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
                    Text(
                      "Total: ฿${cart.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: cart.items.isEmpty
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Order placed successfully!"),
                                ),
                              );
                              cart.clear();
                            },
                      child: const Text("Checkout"),
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