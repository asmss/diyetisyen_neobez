import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neobez/admin_chat_list_page.dart';
import 'package:neobez/chatbotPage.dart';
import 'package:neobez/foodliste.dart';
import 'package:neobez/homePage.dart';
import 'package:neobez/real_time_chat.dart';
import 'package:neobez/user_task_page.dart';

const String adminId = "cRTiUP8L8BUvnPFBUulG6S6RrWg1";

class Indexpage extends StatefulWidget {
  const Indexpage({super.key});

  @override
  State<Indexpage> createState() => _IndexpageState();
}

class _IndexpageState extends State<Indexpage> {
  int index_no = 0;
  late final String currentUserId;
  late final bool isAdmin;
  late final List<Widget> Pages;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    isAdmin = currentUserId == adminId;

    Pages = [
      HomePage(),
      ChatbotPage(),
      isAdmin
          ? const AdminChatListPage()
          : ChatPage(userId: currentUserId),
      YiyecekListesiSayfasi(),
      TasksPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      body: Pages[index_no],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30), bottom: Radius.circular(30)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // kesinlikle fixed olmalı
            backgroundColor: const Color(0xFF00155F), // arka plan rengi
            currentIndex: index_no,
            onTap: (index) {
              setState(() {
                index_no = index;
              });
            },
            selectedFontSize: 15,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            enableFeedback: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Anasayfa"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.mark_chat_unread_outlined), label: "yapay zeka"),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_food_beverage_sharp), label: "Diyetisyen"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Listeler"),
              BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: "Görevler"),

            ],

          ),
        ),
      ),
    );
  }
}
