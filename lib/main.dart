import 'package:beauty_fyi/container/full_screen_image/full_screen_image.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/screens/add_client_screen.dart';
import 'package:beauty_fyi/screens/client_screen.dart';
import 'package:beauty_fyi/screens/full_screen_media_screen.dart';
import 'package:beauty_fyi/screens/gallery_screen.dart';
import 'package:beauty_fyi/screens/landing_screen.dart';
import 'package:beauty_fyi/screens/live_session_screen.dart';
import 'package:beauty_fyi/screens/onboarding_screen.dart';
import 'package:beauty_fyi/screens/post_session_screen.dart';
import 'package:beauty_fyi/screens/register_screen.dart';
import 'package:beauty_fyi/screens/forgot_password_screen.dart';

import 'package:beauty_fyi/screens/dashboard_screen.dart';
import 'package:beauty_fyi/screens/add_service_screen.dart';
import 'package:beauty_fyi/screens/test2.dart';

import 'package:beauty_fyi/screens/testing_screen.dart';
import 'package:beauty_fyi/screens/view_service_screen.dart';
import 'package:beauty_fyi/test/change_notifier_widget.dart';
import 'package:beauty_fyi/test/future_provider_widget.dart';
import 'package:beauty_fyi/test/provider_widget.dart';
import 'package:beauty_fyi/test/state_notifier_widget.dart';
import 'package:beauty_fyi/test/state_provider_widget.dart';
import 'package:beauty_fyi/test/stream_provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  initDatabases();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

Future<void> initDatabases() async {
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'beautyfyi_database.db'),
    onOpen: (db) async {
      print(db);

      // await deleteAllTables(db);
      await db.execute(
        "CREATE TABLE IF NOT EXISTS clients(id INTEGER PRIMARY KEY, client_first_name VARCHAR, client_last_name VARCHAR, client_image TEXT, client_email VARCHAR, client_phone_number VARCHAR )",
      );
      await db.execute(
        "CREATE TABLE IF NOT EXISTS services(id INTEGER PRIMARY KEY, service_name VARCHAR, service_description VARCHAR, service_image TEXT, service_processes TEXT)",
      );
      await db.execute(
        "CREATE TABLE IF NOT EXISTS datetimes(id INTEGER PRIMARY KEY, class_name VARCHAR, date_time VARCHAR)",
      );
      await db.execute(
        "CREATE TABLE IF NOT EXISTS service_media(id INTEGER PRIMARY KEY, session_id INTEGER, service_id INTEGER, user_id INTEGER, file_type VARCHAR, file_path TEXT)",
      );
      await db.execute(
        "CREATE TABLE IF NOT EXISTS sessions(id INTEGER PRIMARY KEY, service_id INTEGER, date_time TEXT, notes TEXT, active INTEGER, current_process INTEGER, client_id VARCHAR)",
      );
      return;
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 3,
  );
  return;
}

Future<void> deleteAllTables(db) async {
  await db.execute("DROP TABLE IF EXISTS services");
  // await db.execute("DROP TABLE IF EXISTS datetimes");
  await db.execute("DROP TABLE IF EXISTS service_media");
  await db.execute("DROP TABLE IF EXISTS sessions");
  // await db.execute("DROP TABLE IF EXISTS clients");
  return;
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
      initialRoute: '/register-screen',
      onGenerateRoute: (RouteSettings settings) {
        final routes = <String, WidgetBuilder>{
          '/': (BuildContext context) => LandingScreen(),
          '/register-screen': (BuildContext context) => RegisterScreen(),
          '/onboarding-screen': (BuildContext context) => OnboardingScreen(),
          '/forgot-password': (BuildContext context) => ForgotPasswordScreen(),
          '/dashboard': (BuildContext context) => DashboardScreen(),
          '/view-service': (BuildContext context) => ViewServiceScreen(
                args: settings.arguments,
              ),
          '/add-service': (BuildContext context) =>
              CreateServiceScreen(args: settings.arguments),
          '/add-client-screen': (BuildContext context) => AddClientScreen(),
          '/full-screen-image': (BuildContext context) => FullScreenImage(),
          '/full-screen-media': (BuildContext context) =>
              FullScreenMediaScreen(args: settings.arguments),
          '/gallery-screen': (BuildContext context) =>
              GalleryScreen(args: settings.arguments),
          '/live-session': (BuildContext context) =>
              LiveSessionScreen(args: settings.arguments),
          '/client-screen': (BuildContext context) =>
              ClientScreen(args: settings.arguments),
          '/post-session-screen': (BuildContext context) =>
              PostSessionScreen(args: settings.arguments),
          '/test': (BuildContext context) => Test(),
          '/provider': (BuildContext context) => ProviderWidget(),
          '/state_provider': (BuildContext context) => StateProviderWidget(),
          '/stream_provider': (BuildContext context) => StreamProviderWidget(),
          '/future_provider': (BuildContext context) => FutureProviderwidget(),
          '/change_notifier': (BuildContext context) => ChangeNotifierWidget(),
          '/state_notifier': (BuildContext context) => StateNotifierWidget(),
        };
        WidgetBuilder? builder = routes[settings.name!];
        return MaterialPageRoute(
          builder: (ctx) {
            return builder!(ctx);
          },
          settings: settings,
        );
      },
    );
  }
}
