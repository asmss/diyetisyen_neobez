import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTaskPage extends StatefulWidget {
  const AdminTaskPage({super.key});

  @override
  State<AdminTaskPage> createState() => _AdminTaskPageState();
}

class _AdminTaskPageState extends State<AdminTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedUserId;

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, 'email': doc['email'], 'username': doc['username']})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTasksForSelectedUser() async {
    if (_selectedUserId == null) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_selectedUserId)
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

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _pickStartTime() async {
    DateTime? picked = await _pickDateTime(_startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  void _pickEndTime() async {
    DateTime? picked = await _pickDateTime(_endTime);
    if (picked != null) setState(() => _endTime = picked);
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate() && _startTime != null && _endTime != null && _selectedUserId != null) {
      int calories = int.tryParse(_calorieController.text) ?? 0;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedUserId)
          .collection('tasks')
          .add({
        'title': _titleController.text,
        'description': _descController.text,
        'calories': calories,
        'startTime': _startTime,
        'endTime': _endTime,
        'completed': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Görev başarıyla oluşturuldu!")));
      _titleController.clear();
      _descController.clear();
      _calorieController.clear();
      setState(() {
        _startTime = null;
        _endTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen tüm alanları doldurun!")));
    }
  }

  Future<void> toggleTaskCompletion(String taskId, bool completed) async {
    if (_selectedUserId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_selectedUserId)
        .collection('tasks')
        .doc(taskId)
        .update({'completed': !completed});
    setState(() {});
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2,'0')}/${dateTime.month.toString().padLeft(2,'0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}";
  }

  Widget _buildTaskList() {
    if (_selectedUserId == null) return const SizedBox.shrink();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getTasksForSelectedUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final tasks = snapshot.data!;
        if (tasks.isEmpty) return const Text("Görev yok", style: TextStyle(color: Colors.grey));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isCompleted = task['completed'] as bool;
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  task['title'],
                  style: TextStyle(
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${task['description']}\n${formatDateTime(task['startTime'])} - ${formatDateTime(task['endTime'])}\nKalori: ${task['calories']}",
                  style: TextStyle(
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : Colors.black),
                ),
                isThreeLine: true,
                trailing: Checkbox(
                  value: isCompleted,
                  onChanged: (val) => toggleTaskCompletion(task['id'], isCompleted),
                  activeColor: Colors.green,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Görev Oluştur"),
        backgroundColor: const Color(0xFF00155F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kullanıcı Seç",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  value: _selectedUserId,
                  items: users
                      .map((user) => DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text(user['email']),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedUserId = val),
                  validator: (val) => val == null ? "Kullanıcı seçiniz" : null,
                );
              },
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Görev Başlığı",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (val) =>
                    val == null || val.isEmpty ? "Başlık giriniz" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: "Açıklama",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (val) =>
                    val == null || val.isEmpty ? "Açıklama giriniz" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _calorieController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Kalori (opsiyonel)",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickStartTime,
                          child: Text(_startTime == null
                              ? "Başlangıç Tarih & Saat"
                              : formatDateTime(_startTime!)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickEndTime,
                          child: Text(_endTime == null
                              ? "Bitiş Tarih & Saat"
                              : formatDateTime(_endTime!)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text(
                      "Görevi Kaydet",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTaskList(),
          ],
        ),
      ),
    );
  }
}
