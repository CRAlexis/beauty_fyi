import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/providers/settings-provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsNotifierProvider =
    StateNotifierProvider.autoDispose((ref) => SettingsNotifier());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(settingsNotifierProvider);
    return Scaffold(
        appBar: CustomAppBar(
            centerTitle: false,
            focused: true,
            transparent: false,
            titleText: "Settings",
            leftIcon: Icons.arrow_back,
            showMenuIcon: false,
            leftIconClicked: () => Navigator.of(context).pop(),
            automaticallyImplyLeading: false),
        body: ProviderListener(
          onChange: (BuildContext context, state) {
            if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    duration: Duration(minutes: 2),
                    action: SnackBarAction(
                        label: "refresh",
                        onPressed: () => context
                            .read(settingsNotifierProvider.notifier)
                            .initialise())),
              );
            }
          },
          provider: settingsNotifierProvider,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: state is SettingsLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : state is SettingsLoaded
                    ? Container(
                        padding: EdgeInsets.all(10),
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            // CheckboxListTile(value: value, onChanged: onChanged)(
                            CheckboxListTile(
                              title: const Text('Vibrations'),
                              subtitle:
                                  Text("Allow vibrations during live sessions"),
                              value: state.appSettings.vibrateSetting,
                              onChanged: (bool? value) {
                                context
                                    .read(settingsNotifierProvider.notifier)
                                    .update(AppSettings(
                                        vibrateSetting: (value as bool)));
                              },
                              checkColor: Colors.white,
                              activeColor: colorStyles['green'],
                            )
                          ],
                        ))
                    : Container(),
          ),
        ));
  }
}
