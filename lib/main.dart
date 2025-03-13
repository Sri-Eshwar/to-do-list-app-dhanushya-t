import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
        ),
        home: TodoScreen(),
      ),
    );
  }
}

class TodoProvider extends ChangeNotifier {
  List<String> _tasks = [];
  List<String> get tasks => _tasks;

  TodoProvider() {
    _loadTasks();
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tasks = (prefs.getStringList('tasks') ?? []);
    notifyListeners();
  }

  void addTask(String task) async {
    _tasks.add(task);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', _tasks);
  }

  void removeTask(int index) async {
    _tasks.removeAt(index);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', _tasks);
  }
}

class TodoScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter To-Do List', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter a task',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          todoProvider.addTask(_controller.text);
                          _controller.clear();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: todoProvider.tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.task_alt, color: Colors.green),
                      title: Text(
                        todoProvider.tasks[index],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => todoProvider.removeTask(index),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
