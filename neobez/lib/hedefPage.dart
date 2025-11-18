import 'package:flutter/material.dart';

class HedefSayfasi extends StatelessWidget {
  const HedefSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController kiloHedefi = TextEditingController();
    final TextEditingController kaloriHedefi = TextEditingController();
    final TextEditingController proteinHedefi = TextEditingController();
    final TextEditingController karbonhidratHedefi = TextEditingController();
    final TextEditingController yagHedefi = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00155F),
        title: const Text("Hedef Belirleme", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _inputAlani("Kilo Hedefi (kg)", kiloHedefi, type: TextInputType.number),
            _inputAlani("Günlük Kalori Hedefi", kaloriHedefi, type: TextInputType.number),
            _inputAlani("Protein Hedefi (g)", proteinHedefi, type: TextInputType.number),
            _inputAlani("Karbonhidrat Hedefi (g)", karbonhidratHedefi, type: TextInputType.number),
            _inputAlani("Yağ Hedefi (g)", yagHedefi, type: TextInputType.number),
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
