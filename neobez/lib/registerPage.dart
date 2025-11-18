import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neobez/login.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  bool _obscureText = true;

  Future<User?> Kayit_yap(String username, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String mesaj = "";
      if (e.code == 'email-already-in-use') {
        mesaj = "Bu e-posta zaten kullanılıyor!";
      } else if (e.code == 'invalid-email') {
        mesaj = "Geçersiz e-posta adresi!";
      } else if (e.code == 'weak-password') {
        mesaj = "Şifre çok zayıf!";
      } else {
        mesaj = "Kayıt hatası: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
      return null;
    } catch (e) {
      print("Kayıt hatası: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 120, 20, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_circle_rounded,
              size: 120,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 20),
            _inputCard(
                const Icon(Icons.person, color: Colors.greenAccent),
                usernameController,
                "Kullanıcı Adı"),
            const SizedBox(height: 15),
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
                User? user = await Kayit_yap(
                  usernameController.text,
                  emailController.text,
                  passwordController.text,
                );

                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
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
                "KAYIT OL",
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
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                "Zaten hesabın var mı? Giriş Yap",
                style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard(
      Icon icon, TextEditingController controller, String hint) {
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

  Widget _passwordCard(
      Icon icon, TextEditingController controller, String hint) {
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
