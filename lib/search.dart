import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'authenticationService.dart';
import 'cart.dart';
import 'package:provider/provider.dart';
import 'book.dart';
import 'favoriteservice.dart';
import 'edit.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});
  final CollectionReference booksRef = FirebaseFirestore.instance.collection(
    'booktells',
  );

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  late CollectionReference booksRef = widget.booksRef;
  String query = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> toggleFavorite(Book book) async {
    final docRef = FirebaseFirestore.instance
        .collection("favorites")
        .doc(book.id);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        "itemId": book.id,
        "name": book.name,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("th-TH");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);

    // เลือกเสียงไทยถ้ามี
    var voices = await flutterTts.getVoices;
    for (var voice in voices) {
      if (voice['locale'] == 'th-TH') {
        await flutterTts.setVoice(voice);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: focusNode,
          controller: _controller,
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
          ), // ✅ white text
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
                        (context) => AlertDialog(
                          title: Text(doc['name']),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  doc['image'], // doc['image'] ควรเป็น path แบบ 'images/xxx.jpg'
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
                            AuthenticationService().getEmail() ==
                                    "phiriyaporn.y@ku.th"
                                ? AuthenticationService().getEmail() == "Guest"
                                    ? const SizedBox.shrink()
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF780C28,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Delete'),
                                            onPressed: () async {
                                              // แสดง Dialog ยืนยัน
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'ลบหนังสือ',
                                                      ),
                                                      content: const Text(
                                                        'คุณต้องการลบหนังสือเล่มนี้หรือไม่?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'ยกเลิก',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'ลบ',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              // ถ้ากด "ลบ"
                                              if (confirm == true) {
                                                await FirebaseFirestore.instance
                                                    .collection('booktells')
                                                    .doc(
                                                      doc.id,
                                                    ) // ใช้ id ของ document
                                                    .delete();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'ลบหนังสือเรียบร้อยแล้ว',
                                                    ),
                                                  ),
                                                );
                                              }

                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),

                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0C783D,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Edit'),
                                            onPressed: () async {
                                              // แสดง Dialog ยืนยัน
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'แก้ไขหนังสือ',
                                                      ),
                                                      content: const Text(
                                                        'คุณต้องการแก้ไขหนังสือเล่มนี้หรือไม่?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'ยกเลิก',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ); // ปิด Dialog แล้ว return true
                                                          },
                                                          child: const Text(
                                                            'แก้ไข',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              // ถ้ากด "แก้ไข"
                                              if (confirm == true) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            EditBookPage(
                                                              docid: doc.id,
                                                            ), // ✅ ส่ง docId
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF103F91),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Add to cart'),
                                        onPressed: () {
                                          final userEmail =
                                              AuthenticationService()
                                                  .getEmail();

                                          if (userEmail == "Guest") {
                                            // ยังไม่ได้ login -> แจ้งเตือน
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'กรุณาเข้าสู่ระบบก่อนเพิ่มสินค้าในตะกร้า',
                                                ),
                                              ),
                                            );
                                          } else {
                                            // เพิ่มเข้าสู่ cart
                                            Provider.of<CartProvider>(
                                              context,
                                              listen: false,
                                            ).addItem(
                                              doc.id,
                                              doc["name"] ?? "Unknown",
                                              (doc["price"] as num?)
                                                      ?.toDouble() ??
                                                  0.0,
                                              doc["image"] ?? "",
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'เพิ่มสินค้าเรียบร้อยแล้ว',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: FavoriteIcon(
                                        bookId: doc.id,
                                        image: doc["image"] ?? "",
                                        name: doc["name"] ?? "Unknown",
                                        price: doc["price"]?.toDouble() ?? 0.0,
                                      ),
                                      onPressed: () {
                                        toggleFavorite(
                                          Book(
                                            id: doc.id,
                                            name: doc["name"] ?? "Unknown",
                                            price:
                                                doc["price"]?.toDouble() ?? 0.0,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // ปุ่มปิด
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 30,
                                    ),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                  child: const Text('ปิด'),
                                ),

                                // ปุ่มฟังรีวิว
                                ElevatedButton.icon(
                                  onPressed:
                                      () => _speak(
                                        "ชื่อหนังสือ: ${doc['name']}\nรีวิว: ${doc['review']}",
                                      ),
                                  icon: const Icon(
                                    Icons.surround_sound,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "ฟังรีวิว",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF103F91),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ],
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
                        child: Image.asset(
                          doc['image'], // doc['image'] ควรเป็น path แบบ 'images/xxx.jpg'
                          height: 300,
                          fit: BoxFit.cover,
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
