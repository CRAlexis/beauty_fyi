import 'dart:convert';

ToDoItem todoItemFromJson(String str) => ToDoItem.fromJson(json.decode(str));

String todoItemToJson(ToDoItem data) => json.encode(data.toJson());

class ToDoItem {
  int leading;
  String title;
  ToDoItem({required this.leading, required this.title});

  factory ToDoItem.fromJson(Map<String, dynamic> json) =>
      ToDoItem(leading: json['leading'], title: json['title']);

  Map<String, dynamic> toJson() => {"leading": leading, "title": title};
}
