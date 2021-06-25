import 'package:beauty_fyi/container/textfields/email_textfield.dart';
import 'package:beauty_fyi/container/textfields/password_textfield.dart';
import 'package:beauty_fyi/container/landing_page/action_button.dart';
import 'package:beauty_fyi/container/landing_page/login_label.dart';
import 'package:beauty_fyi/providers/register_provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerNotifierProvider =
    StateNotifierProvider.autoDispose<RegisterNotifier, RegisterState>(
        (ref) => RegisterNotifier());

class RegisterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final registerProviderController = watch(registerNotifierProvider.notifier);
    final state = watch(registerNotifierProvider);

    return Scaffold(
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(children: <Widget>[
              Container(
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
                      ]))),
              Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 120.0,
                      ),
                      child: Form(
                          key: registerProviderController.form,
                          autovalidateMode:
                              registerProviderController.autovalidateMode,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 30.0),
                              Text(
                                'Get started with Beauty-fyi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 30.0),
                              ActionButton(
                                  disableTextFields:
                                      state is RegisterLoading ? true : false,
                                  buttonText: "continue",
                                  onPressed: () {
                                    print(
                                        registerProviderController.testString);
                                  }),
                              EmailTextField(
                                disableTextFields:
                                    state is RegisterLoading ? true : false,
                                emailTextFieldController:
                                    registerProviderController
                                        .emailTextFieldController,
                              ),
                              SizedBox(height: 10.0),
                              PasswordTextField(
                                disableTextFields:
                                    state is RegisterLoading ? true : false,
                                passwordTextFieldController:
                                    registerProviderController
                                        .passwordTextFieldController,
                              ),
                              SizedBox(height: 10.0),
                              ActionButton(
                                  disableTextFields:
                                      state is RegisterLoading ? true : false,
                                  buttonText: "continue",
                                  onPressed: () {
                                    registerProviderController
                                        .register(context);
                                  }),
                              ProviderListener(
                                onChange: (context, state) {
                                  if (state is RegisterError)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(state.message)));
                                },
                                provider: registerNotifierProvider,
                                child: Container(),
                              ),
                              LoginLabel()
                            ],
                          ))))
            ])));
  }
}
