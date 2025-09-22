import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'bookdetails.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'drawer.dart';

class BookTellScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const BookTellScreen({super.key, required this.onToggleTheme});

  @override
  _BookTellState createState() => _BookTellState();
}

class _BookTellState extends State<BookTellScreen> {
  final formkey = GlobalKey<FormState>();
  BookDetails myBooktell = BookDetails();
  CollectionReference booktellCollection =
      FirebaseFirestore.instance.collection('booktells');

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
  );

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? hint,
    required FormFieldSetter<String> onSaved,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int minLines = 1,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF103F91)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('เพิ่มหนังสือใหม่'),
        backgroundColor: const Color(0xFF103F91),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              _buildTextField(
                label: "ชื่อหนังสือ",
                hint: "เช่น ความทรงจำครั้งที่ร้าว",
                icon: Icons.book,
                onSaved: (val) => myBooktell.name = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนชื่อหนังสือ").call,
              ),
              _buildTextField(
                label: "รูปภาพ",
                hint: "URL รูปภาพหนังสือ",
                icon: Icons.image,
                onSaved: (val) => myBooktell.image = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนที่อยู่รูปภาพ").call,
              ),
              _buildTextField(
                label: "ผู้เขียน",
                hint: "เช่น มนัส จรรยงค์",
                icon: Icons.person,
                onSaved: (val) => myBooktell.author = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนชื่อผู้เขียน").call,
              ),
              _buildTextField(
                label: "สำนักพิมพ์",
                hint: "ชื่อสำนักพิมพ์",
                icon: Icons.business,
                onSaved: (val) => myBooktell.publisher = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนชื่อสำนักพิมพ์")
                        .call,
              ),
              _buildTextField(
                label: "ราคา (THB)",
                hint: "เช่น 250",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                onSaved: (val) => myBooktell.price = int.parse(val ?? '0'),
                validator: RequiredValidator(errorText: "กรุณาป้อนราคา").call,
              ),
              _buildTextField(
                label: "รีวิว",
                hint: "เขียนรีวิวสั้นๆ",
                icon: Icons.rate_review,
                onSaved: (val) => myBooktell.review = val ?? '',
                validator:
                    RequiredValidator(errorText: "กรุณาป้อนรีวิว").call,
                minLines: 4,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 20),

              // ปุ่ม Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF103F91),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกข้อมูล',
                      style: TextStyle(fontSize: 18)),
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

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('บันทึกข้อมูลเรียบร้อย')),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(onToggleTheme: widget.onToggleTheme),
    );
  }
}
