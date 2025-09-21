class Book {
  final String id;
  final String  name;
  final String? email;
  final double? price;
  final String? image;
  

  Book({
    required this.id,
    required this.name,
    this.email,
    this.price,
    this.image,
  });

  factory Book.fromFirestore(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      email: data['email'] as String?,
      image: data['image'] as String?,
    );
  }
}
