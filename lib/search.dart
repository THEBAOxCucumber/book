import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});
  final CollectionReference booksRef = FirebaseFirestore.instance.collection('booktells');

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  late CollectionReference booksRef = widget.booksRef;
  String query = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          
          controller: _controller,
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
          style: const TextStyle(color: Colors.white, fontSize: 22), // ✅ white text
          decoration: const InputDecoration(
            hintText: "Search books...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: buildResults(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {

      return StreamBuilder<QuerySnapshot>(
      stream: booksRef.snapshots(), // ดึงทุกเอกสาร
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final results =
            snapshot.data!.docs.where((doc) {
              final name = doc['name'].toString().toLowerCase();
              final author = doc['author'].toString().toLowerCase();
              final q = query.toLowerCase();
              return name.contains(q) || author.contains(q);
            }).toList();

        if (results.isEmpty) return const Center(child: Text('ไม่พบหนังสือ'));

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // จำนวนคอลัมน์
            crossAxisSpacing: 12, // ระยะห่างแนวนอน
            mainAxisSpacing: 12, // ระยะห่างแนวตั้ง
            childAspectRatio: 0.65, // อัตราส่วนความสูง/กว้างของแต่ละ card
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // แสดงรายละเอียดหนังสือ
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text(doc['name']),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  doc['image'],
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 10),
                                Text('ราคา: ${doc['price']} THB'),
                                Text('ผู้เขียน: ${doc['author']}'),
                                Text('สำนักพิมพ์: ${doc['publisher']}'),
                                const SizedBox(height: 10),
                                Text(doc['review']),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('ปิด'),
                            ),
                          ],
                        ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          doc['image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        doc['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}