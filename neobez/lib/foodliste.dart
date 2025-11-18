import 'package:flutter/material.dart';
import 'package:neobez/csv_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class YiyecekListesiSayfasi extends StatefulWidget {
  @override
  _YiyecekListesiSayfasiState createState() => _YiyecekListesiSayfasiState();
}

class _YiyecekListesiSayfasiState extends State<YiyecekListesiSayfasi> {
  List<FoodItem> tumYiyecekler = [];
  List<FoodItem> filtrelenmisYiyecekler = [];

  Future<List<FoodItem>> yiyecekleriYukle() async {
    final hamVeri = await rootBundle.loadString('lib/assets/turkish_food_dataset_1.csv');
    List<List<dynamic>> listeVeri = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
    ).convert(hamVeri);
    listeVeri.removeAt(0);
    return listeVeri.map((satir) => FoodItem.fromCsv(satir)).toList();
  }

  @override
  void initState() {
    super.initState();
    yiyecekleriYukle().then((yiyecekler) {
      setState(() {
        tumYiyecekler = yiyecekler;
        filtrelenmisYiyecekler = yiyecekler;
      });
    });
  }

  void yiyecekAra(String sorgu) {
    final normalizeSorgu = sorgu.toLowerCase().replaceAll('i', 'ı');
    setState(() {
      filtrelenmisYiyecekler = tumYiyecekler.where((yiyecek) {
        final normalizeIsim = yiyecek.name.toLowerCase().replaceAll('i', 'ı');
        return normalizeIsim.contains(normalizeSorgu);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00155F),
        title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Yiyecek ara...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          onChanged: yiyecekAra,
        ),
      ),
      body: filtrelenmisYiyecekler.isEmpty
          ? Center(
        child: Text(
          'Yiyecek bulunamadı!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: filtrelenmisYiyecekler.length,
        itemBuilder: (context, index) {
          final yiyecek = filtrelenmisYiyecekler[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ExpansionTile(
              leading: Icon(Icons.fastfood, color: Color(0xFF00155F)),
              title: Text(
                yiyecek.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Kalori: ${yiyecek.calorie} kcal'),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.fitness_center, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Protein: ${yiyecek.protein} g'),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.opacity, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Yağ: ${yiyecek.fat} g'),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.grain, color: Colors.brown),
                          SizedBox(width: 8),
                          Text('Karbonhidrat: ${yiyecek.carbs} g'),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
