class FoodItem {
  final String name;
  final double calorie;
  final double carbs;
  final double fat;
  final double protein;

  FoodItem({
    required this.name,
    required this.calorie,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  factory FoodItem.fromCsv(List<dynamic> row) {
    return FoodItem(
      calorie: double.tryParse(row[0].toString()) ?? 0,
      carbs: double.tryParse(row[1].toString()) ?? 0,
      fat: double.tryParse(row[3].toString()) ?? 0,
      protein: double.tryParse(row[6].toString()) ?? 0,
      name: row[11].toString().trim(),
    );
  }
}
