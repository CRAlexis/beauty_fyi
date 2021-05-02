import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SessionModel {
  int id;
  int clientId;
  final DateTime dateTime;
  String notes;
  final bool active;
  int currentProcess;
  final int serviceId;
  SessionModel({
    this.id,
    @required this.clientId,
    @required this.serviceId,
    @required this.dateTime,
    @required this.notes,
    @required this.active,
    @required this.currentProcess,
  });

  Map<String, dynamic> get _toMap {
    return {
      'client_id': clientId,
      'service_id': serviceId,
      'date_time': dateTime.toString(),
      'notes': notes,
      'active': active ? 1 : 0,
      'current_process': currentProcess,
    };
  }

  set setSessionId(int sessionId) {
    this.id = sessionId;
  }

  set setCurrentProcess(int currentProcess) {
    this.currentProcess = currentProcess;
  }

  set setNotes(String notes) {
    this.notes = notes;
  }

  set setClientId(int clientId) {
    this.clientId = clientId;
  }

  Future<List> sessionInit() async {
    try {
      bool sessionIsActive = false;
      String clientName;
      String serviceName;
      int clientId;
      int serviceId;
      SessionModel previousSession;
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      final List<Map<String, dynamic>> query = await db.query("sessions");

      print(query);
      if (query.isEmpty) {
        return [false, null, null];
      }
      query.every((element) {
        if (element['active'] == 1) {
          sessionIsActive = true;
          clientId = element['client_id'];
          serviceId = element['service_id'];
          previousSession = SessionModel(
              id: element['id'],
              clientId: element['client_id'],
              dateTime: DateTime.parse(element['date_time']),
              notes: element['notes'],
              active: element['active'] == 1,
              currentProcess: element['current_process'],
              serviceId: element['service_id']);
          return false;
        }
        return true;
      });
      if (sessionIsActive) {
        List<Map<String, dynamic>> clientQuery =
            await db.query('clients', where: "id = ?", whereArgs: [clientId]);
        clientName = clientQuery.first['client_name'];
        List<Map<String, dynamic>> serviceQuery =
            await db.query('services', where: "id = ?", whereArgs: [serviceId]);
        serviceName = serviceQuery.first['service_name'];
      }
      return [sessionIsActive, clientName, serviceName, previousSession];
    } catch (error) {
      print(error);
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<int> startSession(SessionModel sessionModel) async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));

      final List<Map<String, dynamic>> sessions = await db.query("sessions");
      if (sessions.isNotEmpty) {
        sessions.every((element) {
          if (element['active'] == 1) {
            db.update(
                'sessions',
                SessionModel(
                        id: element['id'],
                        clientId: element['user_id'],
                        serviceId: element['service_id'],
                        dateTime: DateTime.parse(element['date_time']),
                        notes: element['notes'],
                        active: false,
                        currentProcess: element['current_process'])
                    ._toMap,
                where: "id = ?",
                whereArgs: [element['id']]);
          }
          return true;
        });
      }
      await db.insert('sessions', sessionModel._toMap);
      return sessions.length + 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<void> updateSession(SessionModel sessionModel) async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      await db.update('sessions', sessionModel._toMap,
          where: "id = ?", whereArgs: [sessionModel.id]);
      return;
    } catch (e) {
      return Future.error(e, StackTrace.current);
    }
  }
}