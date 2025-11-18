import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String userId; // Açılan sohbetin userId'si
  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  final String adminId = "cRTiUP8L8BUvnPFBUulG6S6RrWg1";
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  /// 🔹 Firestore mesaj referansı
  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.userId)
          .collection("messages");

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final msg = {
      "text": _controller.text,
      "senderId": currentUserId,
      "timestamp": FieldValue.serverTimestamp(),
    };

    final chatDocRef = FirebaseFirestore.instance.collection("chats").doc(widget.userId);

    // Eğer chat doc yoksa oluştur
    final chatDoc = await chatDocRef.get();
    if (!chatDoc.exists) {
      await chatDocRef.set({
        "createdAt": FieldValue.serverTimestamp(),
        "lastMessage": msg["text"],
      });
    } else {
      // varsa son mesajı güncelle
      await chatDocRef.update({
        "lastMessage": msg["text"],
      });
    }

    // Mesajı ekle
    await chatDocRef.collection("messages").add(msg);

    _controller.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentUserId == adminId
            ? "Kullanıcı ile Sohbet"
            : "Diyetisyen ile Sohbet",style: const TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF00155F),
      ),
      body: Column(
        children: [
          // 🔹 Firestore’dan mesajları dinle
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesRef.orderBy("timestamp").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data();
                    final isUserMessage = msg["senderId"] == currentUserId;

                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Color(0xFF00155F)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg["text"] ?? "",style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 Mesaj yazma alanı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Mesaj yaz...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00155F)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
