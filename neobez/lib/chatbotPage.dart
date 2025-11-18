import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neobez/onerilerPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController mesajController = TextEditingController();
  List<Map<String, dynamic>> mesajlar = [];

  @override
  void initState() {
    super.initState();
    _mesajlariYukle();
  }

  // Firestore'daki mesajları yükle
  Future<void> _mesajlariYukle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chatbot")
          .orderBy("tarih", descending: true)
          .get();

      setState(() {
        mesajlar = snapshot.docs.map((doc) {
          Timestamp? ts = doc["tarih"];
          String tarih = ts != null ? ts.toDate().toString() : "";
          return {
            "id": doc.id,
            "mesaj": doc["mesaj"],
            "tarih": tarih,
            "gonderen": "ai"
          };
        }).toList();
      });
    }
  }

  // Mesaj kaydet
  Future<void> mesajKaydet(String mesaj) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chatbot")
          .add({
        "mesaj": mesaj,
        "tarih": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Öneri kaydedildi"))
      );

      _mesajlariYukle();
    } else {
      print("Kullanıcı login değil");
    }
  }

  // AI mesaj gönderme
  Future<void> aiMesajGonder(String metin) async {
    setState(() {
      mesajlar.insert(0, {"mesin": metin, "gonderen": "kullanici"});
    });

    var apikey = "AIzaSyA5BRg1GREBKnByzAHv_P5zq-IzqbjcPco";
    var response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apikey'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {"parts": [{"text": metin}]}
        ]
      }),
    );

    String cevap = "Hata oluştu, tekrar deneyin.";
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      cevap = data["candidates"][0]["content"]["parts"][0]["text"];
    }

    // AI cevabı ekle
    setState(() {
      mesajlar.insert(0, {"mesin": cevap, "gonderen": "ai"});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("NEOBEZ DESTEKÇİN", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OnerilerPage()));
              },
              icon: const Icon(Icons.settings_suggest, color: Colors.white))
        ],
        backgroundColor: const Color(0xFF00155F),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: mesajlar.length,
              itemBuilder: (context, index) {
                bool kullaniciMi = mesajlar[index]['gonderen'] == 'kullanici';
                return Align(
                  alignment: kullaniciMi
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: kullaniciMi ? Color(0xFF00155F) : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: kullaniciMi ? Radius.circular(16) : Radius.zero,
                        bottomRight: kullaniciMi ? Radius.zero : Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            mesajlar[index]['mesin'] ?? mesajlar[index]['mesaj'],
                            style: TextStyle(
                                color: kullaniciMi ? Colors.white : Colors.black,
                                fontSize: 15),
                          ),
                        ),
                        if (!kullaniciMi)
                          IconButton(
                            icon: Icon(Icons.save, color: const Color(0XFF05D0A0), size: 22),
                            onPressed: () {
                              mesajKaydet(mesajlar[index]['mesin'] ?? mesajlar[index]['mesaj']);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mesajController,
                    decoration: InputDecoration(
                      hintText: "Mesaj yaz...",
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00155F),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (mesajController.text.isNotEmpty) {
                        aiMesajGonder(mesajController.text);
                        mesajController.clear();
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
