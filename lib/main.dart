import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() => runApp(ProviderScope(child: ToDoApp()));

final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(tasks: [
    Task(id: 1, label: "Walk the dog"),
    Task(id: 2, label: "Feed the cat"),
    Task(id: 3, label: "Water the plants"),
    Task(id: 4, label: "Call grandpa, ask to be included in Will"),
  ]);
});

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To-do App",
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("To-do List App"),
      ),
      body: Column(children: [
        const SizedBox(height: 40),
        const Text(
          "Bernt's List",
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 30),
        TaskList(),
        const SizedBox(height: 60),
        Indicator()
      ]),
    );
  }
}

class TaskList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Watch taskprovider for any changes in task state
    var tasks = ref.watch(tasksProvider);

    return Column(
      children: tasks.map((task) => TaskItem(task: task)).toList(),
    );
  }
}

class TaskItem extends ConsumerWidget {
  final Task task;

  TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Checkbox(
            value: task.completed,
            onChanged: (newValue) =>
                ref.read(tasksProvider.notifier).toggleCheckbox(task.id)),
        Text(
          task.label,
          style: const TextStyle(fontSize: 16),
        )
      ],
    );
  }
}

class Indicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var allTasks = ref.watch(tasksProvider);

    var completedTasks = allTasks.where((task) {
      return task.completed == true;
    }).length;
    var percentText = (completedTasks / allTasks.length) * 100;

    return CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 12.0,
        progressColor: Colors.green,
        percent: completedTasks / allTasks.length,
        center: Text("$percentText",
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)));
  }
}

@immutable
class Task {
  final int id;
  final String label;
  final bool completed;
  //Constructor
  Task({required this.id, required this.label, this.completed = false});

  //Replaces values of Task
  Task copyWith({int? id, String? label, bool? completed}) {
    return Task(
        id: id ?? this.id,
        label: label ?? this.label,
        completed: completed ?? this.completed);
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier({tasks}) : super(tasks);

  void toggleCheckbox(int taskId) {
    state = [
      //goes through tasks (items), changes completed value at task with certain id
      for (final item in state)
        if (taskId == item.id)
          item.copyWith(completed: !item.completed)
        else
          item
    ];
  }
}
