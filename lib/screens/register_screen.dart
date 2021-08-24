import 'package:beauty_fyi/container/textfields/default_textfield.dart';
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
  final GlobalKey<FormState> form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final registerProviderController =
        context.read(registerNotifierProvider.notifier);
    final state = watch(registerNotifierProvider);
    return Scaffold(
        body: ProviderListener(
            onChange: (context, state) {
              if (state is RegisterError)
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
            },
            provider: registerNotifierProvider,
            child: GestureDetector(
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
                              key: form,
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
                                  UpdatedTextField(
                                      iconData: Icons.email_outlined,
                                      hintText: "",
                                      labelText: "Email",
                                      textInputType: TextInputType.emailAddress,
                                      stylingIndex: 0,
                                      disableTextFields:
                                          state is RegisterLoading
                                              ? true
                                              : false,
                                      defaultTextFieldController:
                                          registerProviderController
                                              .emailAddressController,
                                      focusNode: registerProviderController
                                          .emailAddressFocusNode,
                                      errorText: context
                                          .read(
                                              registerNotifierProvider.notifier)
                                          .emailErrorText),
                                  SizedBox(height: 10.0),
                                  UpdatedTextField(
                                      iconData: Icons.lock,
                                      hintText: "",
                                      labelText: "password",
                                      textInputType: TextInputType.text,
                                      obscureText: true,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      stylingIndex: 0,
                                      disableTextFields:
                                          state is RegisterLoading
                                              ? true
                                              : false,
                                      defaultTextFieldController:
                                          registerProviderController
                                              .passwordController,
                                      focusNode: registerProviderController
                                          .passwordFocusNode,
                                      errorText: context
                                          .read(
                                              registerNotifierProvider.notifier)
                                          .passwordErrorText),
                                  SizedBox(height: 10.0),
                                  ActionButton(
                                      disableTextFields:
                                          state is RegisterLoading
                                              ? true
                                              : false,
                                      buttonText: "continue",
                                      onPressed: () {
                                        registerProviderController
                                            .register(context);
                                      }),
                                  LoginLabel()
                                ],
                              ))))
                ]))));
  }
}
