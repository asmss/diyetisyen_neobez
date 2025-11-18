import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neobez/ProfilPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  List<int> currentWeekDays = [];

  double taskProgress = 0;
  int caloriesTaken = 0;
  int calorieGoal = 2000;
  int waterTaken = 0;
  int waterGoal = 5;
  double weight = 0;
  double weightGoal = 70;

  double waterProgress = 0;
  double taskProgressPercent = 0;

  @override
  void initState() {
    super.initState();
    currentWeekDays = getCurrentWeekDays();
    fetchProgressData();
  }

  List<int> getCurrentWeekDays() {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)).day);
  }

  Future<void> fetchProgressData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    final totalTasks = tasksSnapshot.docs.length;
    final completedTasks = tasksSnapshot.docs.where((doc) => doc['completed'] == true).length;

    num tempCalories = 0;
    for (var doc in tasksSnapshot.docs) {
      if (doc['completed'] == true && doc.data().containsKey('calories')) {
        tempCalories += (doc['calories']) ?? 0;
      }
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        taskProgress = totalTasks > 0 ? completedTasks / totalTasks : 0;
        taskProgressPercent = taskProgress;
        caloriesTaken = (tempCalories).toInt();
        calorieGoal = data['calorieGoal'] ?? 2000;
        waterTaken = data['waterTaken'] ?? 0;
        waterGoal = data['waterGoal'] ?? 5;
        waterProgress = waterTaken / waterGoal;
        weight = (data['currentWeight'] ?? 0).toDouble();
        weightGoal = (data['goalWeight'] ?? 70).toDouble();
      });
    }
  }

  void increaseWater() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (waterTaken < waterGoal) {
      waterTaken += 1;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'waterTaken': waterTaken});
      setState(() {
        waterProgress = waterTaken / waterGoal;
      });
    }
  }

  void decreaseWater() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (waterTaken > 0) {
      waterTaken -= 1;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'waterTaken': waterTaken});
      setState(() {
        waterProgress = waterTaken / waterGoal;
      });
    }
  }

  void updateWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Kilonuzu girin"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "kg"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              double? newWeight = double.tryParse(controller.text);
              if (newWeight != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({'currentWeight': newWeight});
                setState(() {
                  weight = newWeight;
                });
              }
              Navigator.pop(context);
            },
            child: Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00155F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00155F),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilPage()));
            },
            icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
          ),
        ],
        title: const Text(
          "Neobez",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Günler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days
                  .map((e) => Text(
                e,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
              ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: currentWeekDays.map((e) {
                  bool isToday = e == DateTime.now().day;
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isToday
                          ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                          : [],
                    ),
                    child: Text(
                      e.toString(),
                      style: TextStyle(
                        color: isToday ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            // Dashboard üst kısmı: Görev ve Kalori
            // Dashboard üst kısmı: Görev, Alınan Kalori + Hedef Kalori, Kilo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildProgressCard(
                        title: "Görev İlerlemesi",
                        progress: taskProgressPercent,
                        color: Colors.purple.shade400,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCalorieCard(caloriesTaken, calorieGoal),
                          ),
                          const SizedBox(width: 12),


                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildWeightCard()),
              ],
            ),

            const SizedBox(height: 16),
            _buildWaterCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              color: Colors.white,
              backgroundColor: Colors.white24,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text("${(progress * 100).toInt()}%",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  Widget _buildCalorieCard(int taken, int goal) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alınan Kalori",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "$taken / $goal",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.greenAccent.shade400,
                  elevation: 6,
                ),
                onPressed: () {
                  final TextEditingController controller =
                  TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Hedef Kalori Girin"),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "kalori"),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("İptal")),
                        ElevatedButton(
                          onPressed: () async {
                            int? newGoal = int.tryParse(controller.text);
                            if (newGoal != null) {
                              final user =
                                  FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'calorieGoal': newGoal});
                                setState(() {
                                  calorieGoal = newGoal;
                                });
                              }
                            }
                            Navigator.pop(context);
                          },
                          child: Text("Kaydet"),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(Icons.edit, color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildWeightCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.orange.shade500]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Hedef Kilo",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("${weight.toStringAsFixed(1)} kg",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(12),
              backgroundColor: Colors.white,
            ),
            onPressed: updateWeight,
            child: Icon(Icons.add, color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Su İçme",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(8),
                  backgroundColor: Colors.white,
                ),
                onPressed: decreaseWater,
                child: Icon(Icons.remove, color: Colors.blue, size: 24),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: waterProgress.clamp(0.0, 1.0),
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                    minHeight: 12,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(8),
                  backgroundColor: Colors.white,
                ),
                onPressed: increaseWater,
                child: Icon(Icons.add, color: Colors.blue, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("$waterTaken / $waterGoal Bardak",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
