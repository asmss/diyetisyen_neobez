import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  Future<List<Map<String, dynamic>>> getUserTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('startTime')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'title': doc['title'],
        'description': doc['description'],
        'calories': doc.data().containsKey('calories') ? doc['calories'] : 0,
        'startTime': doc['startTime'].toDate(),
        'endTime': doc['endTime'].toDate(),
        'completed': doc['completed'],
      };
    }).toList();
  }

  void toggleTaskCompletion(String taskId, bool completed, int calories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .update({'completed': !completed});

    // Kalori güncellemesi
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();
    int currentCalories = (userDoc.data()?['caloriesTaken'] ?? 0);
    int newCalories = completed
        ? currentCalories - calories // geri alıyoruz
        : currentCalories + calories; // ekliyoruz
    await userDocRef.update({'caloriesTaken': newCalories});

    setState(() {}); // Listeyi güncelle
  }

  void incrementWater() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();
    int currentWater = (userDoc.data()?['waterTaken'] ?? 0);
    int waterGoal = (userDoc.data()?['waterGoal'] ?? 5);
    if (currentWater < waterGoal) {
      await userDocRef.update({'waterTaken': currentWater + 1});
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Görevlerim"),
        backgroundColor: const Color(0xFF00155F),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUserTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...tasks.map((task) {
                if(task['title'].toLowerCase() == "su içme") {
                  // Su içme özel satır
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.blue.shade300,
                    child: ListTile(
                      title: const Text("Su İçme"),
                      subtitle: Text("Günlük hedef: 5 bardak"),
                      trailing: ElevatedButton(
                        onPressed: incrementWater,
                        child: const Text("+"),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => toggleTaskCompletion(task['id'], task['completed'], task['calories']),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: task['completed'] ? Colors.green.shade300 : Colors.purple.shade300,
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle: Text(
                          "${task['startTime'].hour}:${task['startTime'].minute} - ${task['endTime'].hour}:${task['endTime'].minute}\n${task['description']}"),
                      trailing: Icon(task['completed']
                          ? Icons.check_circle
                          : Icons.check_circle_outline),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
