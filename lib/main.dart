import 'package:beauty_fyi/screens/full_screen_image.dart';
import 'package:beauty_fyi/screens/landing_screen.dart';
import 'package:beauty_fyi/screens/live_session_screen.dart';
import 'package:beauty_fyi/screens/sign_up_screen.dart';
import 'package:beauty_fyi/screens/forgot_password_screen.dart';

import 'package:beauty_fyi/screens/dashboard_screen.dart';
import 'package:beauty_fyi/screens/add_service_screen.dart';

import 'package:beauty_fyi/screens/testing_screen.dart';
import 'package:beauty_fyi/screens/view_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  final Future<Database> database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'beautyfyi_database.db'),

    onOpen: (db) async {
      print(db);
      await db.execute(
        "CREATE TABLE IF NOT EXISTS services(id INTEGER PRIMARY KEY, service_name VARCHAR, service_description VARCHAR, service_image TEXT, service_processes TEXT)",
      );
      await db.execute(
        "CREATE TABLE IF NOT EXISTS datetimes(id INTEGER PRIMARY KEY, class_name VARCHAR, date_time VARCHAR)",
      );
      await db.execute("DROP TABLE IF EXISTS service_media");
      await db.execute(
        "CREATE TABLE IF NOT EXISTS service_media(id INTEGER PRIMARY KEY, session_id INTEGER, service_id INTEGER, user_id INTEGER, file_type VARCHAR, file_path TEXT)",
      );
      return db.execute(
        "CREATE TABLE IF NOT EXISTS clients(id INTEGER PRIMARY KEY, client_name VARCHAR)",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 3,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beauty-fyi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/dashboard',
      onGenerateRoute: (RouteSettings settings) {
        final routes = <String, WidgetBuilder>{
          '/': (BuildContext context) => LandingScreen(),
          '/sign-up': (BuildContext context) => SignInScreen(),
          '/forgot-password': (BuildContext context) => ForgotPasswordScreen(),
          '/dashboard': (BuildContext context) => DashboardScreen(),
          '/view-service': (BuildContext context) => ViewServiceScreen(
                args: settings.arguments,
              ),
          '/add-service': (BuildContext context) =>
              CreateServiceScreen(args: settings.arguments),
          '/full-screen-image': (BuildContext context) => FullScreenImage(),
          '/live-session': (BuildContext context) =>
              LiveSessionScreen(args: settings.arguments),
          '/testing-screen': (BuildContext context) => CameraPreviewTest(),
        };
        WidgetBuilder builder = routes[settings.name];
        return MaterialPageRoute(
          builder: (ctx) {
            return builder(ctx);
          },
          settings: settings,
        );
      },
    );
  }
}
