import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnerilerPage extends StatefulWidget {
  @override
  _OnerilerPageState createState() => _OnerilerPageState();
}

class _OnerilerPageState extends State<OnerilerPage> {
  List<Map<String, dynamic>> oneriler = [];

  @override
  void initState() {
    super.initState();
    veritabaniAc();
  }

  // Firestore'dan önerileri çek
  Future<void> veritabaniAc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chatbot")
          .orderBy("tarih", descending: true)
          .get();

      setState(() {
        oneriler = snapshot.docs.map((doc) {
          return {
            "id": doc.id,        // Firestore doc id
            "mesaj": doc["mesaj"],
            "tarih": doc["tarih"] != null
                ? (doc["tarih"] as Timestamp).toDate().toString()
                : "",
          };
        }).toList();
      });
    }
  }

  // Firestore'dan öneri sil
  Future<void> oneriyiSil(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chatbot")
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Öneri silindi")),
      );

      veritabaniAc(); // Listeyi güncelle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kaydedilen Öneriler",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00155F),
      ),
      body: oneriler.isEmpty
          ? Center(child: Text("Henüz öneri kaydedilmedi."))
          : ListView.builder(
        itemCount: oneriler.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                oneriler[index]['mesaj'],
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                "Tarih: ${oneriler[index]['tarih']}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  oneriyiSil(oneriler[index]['id']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
