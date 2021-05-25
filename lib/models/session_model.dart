import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_bundle_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SessionModel {
  int? id;
  int? clientId;
  DateTime dateTime;
  String? notes;
  bool active;
  int? currentProcess;
  int? serviceId;
  String? serviceName;
  SessionModel({
    this.id,
    required this.clientId,
    required this.serviceId,
    required this.dateTime,
    required this.notes,
    required this.active,
    required this.currentProcess,
    this.serviceName,
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

  set setCurrentProcess(int? currentProcess) {
    this.currentProcess = currentProcess;
  }

  set setNotes(String notes) {
    this.notes = notes;
  }

  set setClientId(int clientId) {
    this.clientId = clientId;
  }

  set setActive(bool active) {
    this.active = active;
  }

  Future<List> sessionInit() async {
    try {
      bool sessionIsActive = false;
      String? clientName;
      String? serviceName;
      SessionModel? previousSession;
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      final List<Map<String, dynamic>> query = await db.query("sessions");

      if (query.isEmpty) {
        return [false, null, null];
      }

      query.every((element) {
        if (element['active'] == 1) {
          sessionIsActive = true;
          previousSession = SessionModel(
              id: element['id'],
              clientId: int.parse(element['client_id']),
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
        List<Map<String, dynamic>> clientQuery = await db.query('clients',
            where: "id = ?", whereArgs: [previousSession!.clientId]);
        clientName =
            "${clientQuery.first['client_first_name']} ${clientQuery.first['client_last_name']}";
        List<Map<String, dynamic>> serviceQuery = await db.query('services',
            where: "id = ?", whereArgs: [previousSession!.serviceId]);
        serviceName = serviceQuery.first['service_name'];
      }
      return [sessionIsActive, clientName, serviceName, previousSession];
    } catch (error) {
      print("error $error");
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

  Future<void> endSession() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      await db.update('sessions', this._toMap,
          where: "id = ?", whereArgs: [this.id]);
      return;
    } catch (e) {
      return Future.error(e, StackTrace.current);
    }
  }

  Future<SessionBundleModel> readSessions({required sql, required args}) async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      List<Map<String, dynamic>> query =
          await db.query('sessions', where: sql, whereArgs: args);
      List<SessionModel> sessions = [];
      List<ServiceModel> services = [];
      List<List<ServiceMedia>> serviceMedias = [];
      int i = 0;
      await Future.forEach(query, (Map<String, dynamic> session) async {
        services
            .add(await ServiceModel(id: session['service_id']).readService());
        serviceMedias.add(await ServiceMedia()
            .readServiceMedia(sql: "session_id = ?", args: [session['id']]));

        sessions.add(SessionModel(
          id: session['id'],
          clientId: int.parse(session['client_id']),
          serviceId: session['service_id'],
          dateTime: DateTime.parse(session['date_time']),
          notes: session['notes'],
          active: session['active'] == 1,
          currentProcess: session['current_process'],
        ));
        i++;
        print("index $i");
      });
      print("length: ${serviceMedias.length}");
      return SessionBundleModel(
          sessionModel: sessions,
          serviceModel: services,
          serviceMedia: serviceMedias);
    } catch (e) {
      print(e);
      return Future.error(e, StackTrace.current);
    }
  }
}
