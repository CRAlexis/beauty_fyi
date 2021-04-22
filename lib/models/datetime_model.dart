import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DateTimeModel {
  final DateTime dateTime;
  final String className;
  DateTimeModel({this.dateTime, this.className});

  Map<String, dynamic> toMap() {
    return {'class_name': className, 'date_time': dateTime.toString()};
  }

  Future<bool> insertDateTime(
      {DateTimeModel dateTimeModel, bool overwrite}) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query = await db
          .query('datetimes', where: 'class_name = ?', whereArgs: [className]);
      if (overwrite || query.length == 0) {
        await db.delete('datetimes',
            where: "class_name = ?", whereArgs: [className]);
        int query = await db.insert('datetimes', dateTimeModel.toMap());
        return query == 1;
      }
      return false;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<DateTimeModel> readDateTime() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query = await db
          .query('datetimes', where: 'class_name = ?', whereArgs: [className]);
      if (query.length == 0) {
        print("are we in here");
        throw 'no entries found';
      }
      return DateTimeModel(
          dateTime: DateTime.parse(query[0]['date_time']),
          className: query[0]['class_name']);
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }
}
