import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookSearchDelegate extends SearchDelegate<String> {
  final CollectionReference booksRef = FirebaseFirestore.instance.collection(
    'booktells',
  );
  

  @override
ThemeData appBarTheme(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.copyWith(
    appBarTheme: const AppBarTheme(
      color: Color(0xFF103F91), // สีพื้น AppBar / ช่องค้นหา
      
      iconTheme: IconThemeData(color: Colors.white), // สีไอคอน
      toolbarTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    textTheme: theme.textTheme.copyWith(
      titleMedium: const TextStyle(color: Colors.white), // สีข้อความ
    ),
  );
}



  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
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

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('พิมพ์ชื่อหนังสือหรือผู้เขียนเพื่อค้นหา'));
  }
}