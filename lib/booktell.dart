import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'bookdetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'loginpage.dart';

class BookTellScreen extends StatefulWidget {
  const BookTellScreen({super.key});

  // ฟังก์ชันออกจากระบบ
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // if (context.mounted) {
    //   Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => const LoginPage()),
    //     (Route<dynamic> route) => false,
    //   );
    // }
  }

  @override
  _BookTellState createState() => _BookTellState();
}

class _BookTellState extends State<BookTellScreen> {
  final formkey = GlobalKey<FormState>();
  BookDetails myBooktell = BookDetails();
  CollectionReference booktellCollection = FirebaseFirestore.instance
      .collection('booktells');

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
  );

  Widget _buildTextField({
    required String label,
    String? hint,
    required FormFieldSetter<String> onSaved,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int minLines = 1,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: fieldBorder.copyWith(
              borderSide: const BorderSide(color: Color(0xFF103F91), width: 2),
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          minLines: minLines,
          maxLines: maxLines,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('BookTell'),
        backgroundColor: const Color(0xFF103F91),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => widget._logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              _buildTextField(
                label: "Name Book",
                hint: "เช่น ความทรงจำครั้งที่ร้าว",
                onSaved: (val) => myBooktell.name = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนชื่อหนังสือ").call,
              ),
              _buildTextField(
                label: "Image",
                hint: "ที่อยู่รูปภาพ",
                onSaved: (val) => myBooktell.image = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนที่อยู่รูปภาพ").call,
              ),
              _buildTextField(
                label: "Author",
                hint: "ชื่อผู้เขียน",
                onSaved: (val) => myBooktell.author = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนชื่อผู้เขียน").call,
              ),
              _buildTextField(
                label: "Publisher",
                hint: "ชื่อสำนักพิมพ์",
                onSaved: (val) => myBooktell.publisher = val ?? '',
                validator:
                    RequiredValidator(
                      errorText: "กรุณาป้อนชื่อสำนักพิมพ์",
                    ).call,
              ),
              _buildTextField(
                label: "Price (THB)",
                hint: "เช่น 250",
                keyboardType: TextInputType.number,
                onSaved: (val) => myBooktell.price = int.parse(val ?? '0'),
                validator: RequiredValidator(errorText: "กรุณาป้อนราคา").call,
              ),

              _buildTextField(
                label: "Review",
                hint: "เขียนรีวิวสั้นๆ",
                onSaved: (val) => myBooktell.review = val ?? '',
                validator: RequiredValidator(errorText: "กรุณาป้อนรีวิว").call,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF103F91),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      formkey.currentState!.save();
                      await booktellCollection.add({
                        'name': myBooktell.name,
                        'image': myBooktell.image,
                        'author': myBooktell.author,
                        'publisher': myBooktell.publisher,
                        'price': myBooktell.price,
                        'review': myBooktell.review,
                      });
                      formkey.currentState!.reset();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
