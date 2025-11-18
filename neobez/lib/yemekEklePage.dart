import 'package:flutter/material.dart';

class YemekEkleSayfasi extends StatelessWidget {
  const YemekEkleSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController yemekAdi = TextEditingController();
    final TextEditingController kalori = TextEditingController();
    final TextEditingController protein = TextEditingController();
    final TextEditingController karbonhidrat = TextEditingController();
    final TextEditingController yag = TextEditingController();

    String ogunTipi = "Kahvaltı";

    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00155F),
        title: const Text("Yemek Ekle", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _inputAlani("Yemek Adı", yemekAdi),
            _inputAlani("Kalori", kalori, type: TextInputType.number),
            _inputAlani("Protein (g)", protein, type: TextInputType.number),
            _inputAlani("Karbonhidrat (g)", karbonhidrat, type: TextInputType.number),
            _inputAlani("Yağ (g)", yag, type: TextInputType.number),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: ogunTipi,
              dropdownColor: Colors.grey[800],
              decoration: const InputDecoration(
                labelText: "Öğün Tipi",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
              items: ["Kahvaltı", "Öğle", "Akşam", "Ara Öğün"]
                  .map((tip) => DropdownMenuItem(value: tip, child: Text(tip)))
                  .toList(),
              onChanged: (value) {},
            ),
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
