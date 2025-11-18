import 'package:flutter/material.dart';

class SuSayfasi extends StatelessWidget {
  const SuSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController gunlukHedef = TextEditingController();
    final TextEditingController icilenSu = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00155F),
        title: const Text("Su Takibi", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _inputAlani("Günlük Hedef (ml)", gunlukHedef, type: TextInputType.number),
            _inputAlani("İçilen Su Miktarı (ml)", icilenSu, type: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: SQLite ekleme yapılacak
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Kaydet", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputAlani(String etiket, TextEditingController kontrol, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: kontrol,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: etiket,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }
}
