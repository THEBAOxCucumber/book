import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBookPage extends StatefulWidget {
  final String docid; // รับ id ของหนังสือที่จะแก้ไข

  const EditBookPage({super.key, required this.docid});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('booktells')
          .doc(widget.docid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _priceController.text = data['price']?.toString() ?? '';
        _authorController.text = data['author'] ?? '';
        _imageController.text = data['image'] ?? '';
        _publisherController.text = data['publisher'] ?? '';
        _reviewController.text = data['review'] ?? '';
        _quantityController.text = data['quantity']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint("Error loading book: $e");
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('booktells')
          .doc(widget.docid)
          .update({
        'name': _nameController.text,
        'price': _priceController.text,
        'author': _authorController.text,
        'image': _imageController.text,
        'publisher': _publisherController.text,
        'review': _reviewController.text,
        'quantity' : _quantityController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตหนังสือเรียบร้อยแล้ว')),
      );

      Navigator.pop(context); // กลับไปหน้าก่อนหน้า
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? inputType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขหนังสือ")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: "ชื่อหนังสือ",
                      icon: Icons.book,
                      validator: (v) =>
                          v == null || v.isEmpty ? "กรอกชื่อหนังสือ" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _imageController,
                      label: "ลิงก์รูปภาพ",
                      icon: Icons.image,
                      inputType: TextInputType.url,
                      validator: (v) =>
                          v == null || v.isEmpty ? "กรอกรูปภาพ" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _authorController,
                      label: "นักเขียน",
                      icon: Icons.person,
                      validator: (v) =>
                          v == null || v.isEmpty ? "กรอกนักเขียน" : null,
                    ),
                    const SizedBox(height: 16),
                     _buildTextField(
                      controller: _publisherController,
                      label: "สำนักพิมพ์",
                      icon: Icons.account_balance,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _priceController,
                      label: "ราคา",
                      icon: Icons.attach_money,
                      inputType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? "กรอกราคา" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _reviewController,
                      label: "รีวิว",
                      icon: Icons.rate_review,
                      inputType: TextInputType.multiline,
                      maxLines: 5,
                      validator: (v) =>
                          v == null || v.isEmpty ? "กรอกรีวิว" : null,
                    ),
                    // const SizedBox(height: 16),
                    // _buildTextField(
                    //   controller: _quantityController,
                    //   label: "จำนวนหนังสือ",
                    //   icon: Icons.star,
                    //   inputType: TextInputType.number,
                    //   validator: (v) =>
                    //       v == null || v.isEmpty ? "กรอกจำนวนหนังสือ" : null,
                    // ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF103F91),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saveBook,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "บันทึก",
                          style: TextStyle(fontSize: 16),
                        ),
                        
                      ),
                      
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
                                    
