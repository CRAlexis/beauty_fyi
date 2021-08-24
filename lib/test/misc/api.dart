import 'package:beauty_fyi/test/misc/todos_data.dart';

import 'package:dio/dio.dart';

class API {
  API();

  Future<List<ToDoItem>> getTodos() async {
    try {
      await Future.delayed(Duration(seconds: 3));

      return [
        ToDoItem(leading: 1, title: "new title"),
        ToDoItem(leading: 2, title: "my next title")
      ];
    } on DioError catch (e) {
      return Future.error(e, StackTrace.current);
    }
  }
}
