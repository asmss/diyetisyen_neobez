import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neobez/admin_chat_list_page.dart';
import 'package:neobez/indexPage.dart';
import 'package:neobez/registerPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  final String adminId = "cRTiUP8L8BUvnPFBUulG6S6RrWg1";

  Future<User?> Giris_yap(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giriş yapılamadı! Email veya şifre hatalı.")),
      );
      return null;
    }
  }

  Future<void> createOrUpdateUserInFirestore(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.set({
      'email': user.email,
      'username': user.displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 150, 20, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_circle_rounded,
              size: 120,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 30),
            _inputCard(
                const Icon(Icons.email, color: Colors.greenAccent),
                emailController,
                "Email"),
            const SizedBox(height: 15),
            _passwordCard(
                const Icon(Icons.password, color: Colors.greenAccent),
                passwordController,
                "Şifre"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                User? user =
                await Giris_yap(emailController.text, passwordController.text);
                if (user != null) {
                  await createOrUpdateUserInFirestore(user);
                  if (user.uid == adminId) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminChatListPage()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Indexpage()),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                elevation: 5,
              ),
              child: const Text(
                "GİRİŞ YAP",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Registerpage()),
                );
              },
              child: const Text(
                "Hesabın yok mu? Kayıt Ol",
                style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard(Icon icon, TextEditingController controller, String hint) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white,
      shadowColor: Colors.greenAccent.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          controller: controller,
          cursorColor: Colors.greenAccent,
          decoration: InputDecoration(
            icon: icon,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _passwordCard(Icon icon, TextEditingController controller, String hint) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white,
      shadowColor: Colors.greenAccent.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          controller: controller,
          obscureText: _obscureText,
          cursorColor: Colors.greenAccent,
          decoration: InputDecoration(
            icon: icon,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.greenAccent),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
