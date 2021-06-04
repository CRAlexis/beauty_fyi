import 'dart:async';

import 'package:beauty_fyi/http/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secureStorage;
import 'package:riverpod/riverpod.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterLoaded extends RegisterState {
  const RegisterLoaded();
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is RegisterError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier([RegisterNotifier? state]) : super(RegisterInitial());
  final form = GlobalKey<FormState>();
  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();
  final AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  Future<void> register(BuildContext context) async {
    try {
      state = RegisterLoading();
      await _registerHttpRequest(
          email: emailTextFieldController.text,
          password: passwordTextFieldController.text,
          form: form,
          context: context);
      state = RegisterLoaded();
      state = RegisterInitial();
      return;
    } catch (e) {
      if (e is DioError) {
        state = RegisterError(
            "Unable to register, please check your internet connection");
        return;
      }
      state = RegisterError("Unable to register, please try again");
      return;
    }
  }
}

Future<void> _registerHttpRequest(
    {required String email,
    required String password,
    required GlobalKey<FormState> form,
    required BuildContext context}) async {
  try {
    final storage = new secureStorage.FlutterSecureStorage();
    final HttpService http = HttpService();
    if (!form.currentState!.validate()) {
      // throw ("need validate form");
    }

    final content = new Map<String, dynamic>();
    content['email'] = email;
    content['password'] = password;
    Navigator.pushNamedAndRemoveUntil(
        context, '/onboarding-screen', (route) => false);
    return;

    Response response = await http.postRequest(
        endPoint: 'authentication/register/1', data: content);
    if (response.statusCode == 200) {
      await storage.write(key: "key", value: response.data['key']);
      await storage.write(key: "email", value: content['email']);
      await storage.write(key: "password", value: content['password']);
      return;
    } else {
      // navigate to onboarding process
      // Navigator.pushNamed(requestParameters.context, '/onboarding-screen');

      throw ("unable to sign in");
    }
  } catch (error) {
    print(error);
    throw (error);
  }
}

// MessageAlertDialog(
// message: "Unable to register, please try again.",
// context: requestParameters.context,
// onPressed: () => Navigator.of(requestParameters.context).pop())
// .show();
