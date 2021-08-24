import 'package:beauty_fyi/test/misc/todos_data.dart';
import 'package:riverpod/riverpod.dart';

class ToDoList extends StateNotifier<List<ToDoItem>> {
  ToDoList([List<ToDoItem>? state]) : super([]){
  }

  void add({required String title}) {
    state = [...state, new ToDoItem(leading: state.length + 1, title: title)];
  }

  void toggle(num id) {
    state = [
      for (var todo in state)
        if (todo.leading == id)
          ToDoItem(leading: todo.leading, title: "${todo.title} + (completed)")
        else
          todo
    ];
  }

  List<ToDoItem> getState() {
    return state;
  }
}
