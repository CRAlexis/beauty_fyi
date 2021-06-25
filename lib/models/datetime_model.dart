import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DateTimeModel {
  DateTime? dateTime;
  final String? meta;
  DateTimeModel({this.dateTime, this.meta});

  Map<String, dynamic> toMap() {
    return {'meta': meta, 'date_time': dateTime.toString()};
  }

  set setDateTime(DateTime dateTime) {
    this.dateTime = dateTime;
  }

  Future<void> insertDateTime(bool overwrite) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query = await db
          .query('datetimes', where: 'meta = ?', whereArgs: [this.meta]);
      if (overwrite || query.length == 0) {
        await db.delete('datetimes', where: "meta = ?", whereArgs: [this.meta]);
        await db.insert('datetimes', this.toMap());
      }
      return;
    } catch (error) {
      throw (error);
    }
  }

  ///
  ///If no datetime is found, then the insertDateTime function will run
  Future<DateTimeModel> readDateTime() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query = await db
          .query('datetimes', where: 'meta = ?', whereArgs: [this.meta]);
      if (query.length == 0) {
        this.dateTime = DateTime.now();
        await insertDateTime(true);
        return this;
      }
      return DateTimeModel(
          dateTime: DateTime.parse(query[0]['date_time']),
          meta: query[0]['meta']);
    } catch (error) {
      throw (error);
    }
  }

  Future<bool> removeDateTime() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db
          .delete('datetimes', where: 'meta = ?', whereArgs: [this.meta]);
      return query == 1;
    } catch (error) {
      throw (error);
    }
  }
}
