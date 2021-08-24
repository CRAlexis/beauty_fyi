import 'dart:async';

import 'package:beauty_fyi/http/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secureStorage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  RegisterNotifier([RegisterNotifier? state]) : super(RegisterInitial()) {
    emailAddressController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    // emailAddressFocusNode.addListener(_emailChangeFocus);
    // passwordFocusNode.addListener(_passwordChangeFocus);
  }
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode emailAddressFocusNode = new FocusNode();
  final FocusNode passwordFocusNode = new FocusNode();
  final AutovalidateMode autovalidateMode = AutovalidateMode.always;
  // final Regex emailRegex =
  // ;
  String emailErrorText = "";
  String passwordErrorText = "";
  bool emailIsValid = false;
  bool passwordIsValid = false;

  //validation if string is over one letter
  //regex then email duplication
  void _validateEmail() async {
    try {
      print("1");
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();
      content['email'] = emailAddressController.text;
      print("2");

      if (emailAddressController.text.length == 0) {
        emailErrorText = "";
        emailIsValid = false;
        state = RegisterInitial();
        return;
      }
      print("3");

      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailAddressController.text.trim())) {
        state = RegisterInitial();
        emailErrorText = "Invalid email";
        emailIsValid = false;
        return;
      } else {
        emailErrorText = "";
        emailIsValid = true;
      }

      try {
        Response response = await http.postRequest(
            endPoint: 'authentication/register/check-email/1', data: content);
        print("5");

        response.data['available'] == false
            ? () {
                emailErrorText = "Email already in use";
                emailIsValid = false;
              }()
            : () {
                emailErrorText = "";
                emailIsValid = true;
              }();
        state = RegisterInitial();
        return;
      } catch (e) {
        emailIsValid = false;
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }

  void _validatePassword() {
    if (passwordController.text.length > 0 &&
        passwordController.text.length < 4) {
      passwordErrorText = "Password too short";
      passwordIsValid = false;
    } else {
      passwordErrorText = "";
      passwordIsValid = true;
    }
    state = RegisterInitial();
  }

  Future<void> register(BuildContext context) async {
    try {
      state = RegisterLoading();
      await _registerHttpRequest(
          email: emailAddressController.text,
          password: passwordController.text,
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

  Future<void> _registerHttpRequest(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final storage = new FlutterSecureStorage();
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();

      _validateForm();

      content['email'] = email;
      content['password'] = password;
      Response response = await http.postRequest(
          endPoint: 'authentication/register/1', data: content);
      print(
          "response: ${response.statusCode} | ${response.statusMessage} | ${response.data['key']}");
      if (response.statusCode == 200) {
        await storage.write(key: "key", value: response.data['key']);
        await storage.write(key: "email", value: content['email']);
        await storage.write(key: "password", value: content['password']);
        Navigator.pushNamedAndRemoveUntil(
            context, '/onboarding-screen', (route) => false);
        return;
      } else {
        throw ("Unable to sign up. Please try again.");
      }
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  void _validateForm() {
    if (!emailIsValid || !passwordIsValid) {
      throw 'invalid form';
    }
  }
}
