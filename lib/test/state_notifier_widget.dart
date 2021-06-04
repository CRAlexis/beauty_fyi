import 'package:beauty_fyi/test/misc/state_notifier_todo.dart';
import 'package:beauty_fyi/test/misc/todos_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoListProvider =
    StateNotifierProvider<ToDoList, List<ToDoItem>>((ref) => ToDoList());

class StateNotifierWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final todosController = watch(todoListProvider.notifier);
    final todos = watch(todoListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("change notifier"),
        backgroundColor: Colors.green,
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              for (final todo in todos)
                GestureDetector(
                    onTap: () => todosController.toggle(todo.leading),
                    child: ListTile(
                      leading: Text(todo.leading.toString()),
                      title: Text(todo.title),
                    ))
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => todosController.add(title: "this is a new note"),
        child: Icon(Icons.add),
      ),
    );
  }
}
