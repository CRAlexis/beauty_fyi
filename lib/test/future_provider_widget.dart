import 'package:beauty_fyi/test/misc/api.dart';
import 'package:beauty_fyi/test/misc/todos_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toDoProvider = FutureProvider.autoDispose<List<ToDoItem>>((ref) async {
  return API().getTodos();
});

class FutureProviderwidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    AsyncValue<List<ToDoItem>> toDoItems = watch(toDoProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Future provider"),
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: toDoItems.when(
              data: (data) => ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ListTile(
                        leading: Text(data[index].leading.toString()),
                        title: Text(
                          data[index].title,
                        ),
                      )),
              loading: () => CircularProgressIndicator(),
              error: (error, stacktrace) => Text("this is a new error"))),
    );
  }
}
