import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/providers/register_provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HoldingScreen extends StatefulWidget {
  const HoldingScreen({Key? key}) : super(key: key);

  @override
  _HoldingScreenState createState() => _HoldingScreenState();
}

class _HoldingScreenState extends State<HoldingScreen> {
  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => _autoSignIn(context));
    } catch (e) {}
  }

  void _autoSignIn(context) async {
    final storage = new FlutterSecureStorage();
    if (await storage.read(key: 'email') != null) {
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();
      content['email'] = await storage.read(key: 'email');
      content['password'] = await storage.read(key: 'password');
      try {
        await http.postRequest(
            endPoint: 'authentication/sign-in/1', data: content);
        Navigator.pushReplacementNamed(context, '/dashboard');
      } catch (e) {
        Navigator.pushReplacementNamed(context, '/register-screen');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/register-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colorStyles['dark_purple']!,
                    colorStyles['light_purple']!,
                    colorStyles['blue']!,
                    colorStyles['green']!
                  ]),
            )));
  }
}
