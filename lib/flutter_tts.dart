import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TtsExample(),
    );
  }
}

class TtsExample extends StatefulWidget {
  @override
  _TtsExampleState createState() => _TtsExampleState();
}

class _TtsExampleState extends State<TtsExample> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController _controller = TextEditingController();

  Future _speak() async {
    if (_controller.text.isNotEmpty) {
      await flutterTts.setLanguage("th-TH"); // ตั้งค่าเป็นภาษาไทย
      await flutterTts.setPitch(1.0);        // ความสูง-ต่ำของเสียง
      await flutterTts.setSpeechRate(0.5);   // ความเร็ว
      await flutterTts.speak(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter TTS Example")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "พิมพ์ข้อความที่นี่...",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speak,
              child: Text("พูดข้อความ"),
            ),
          ],
        ),
      ),
    );
  }
}
