import 'package:beauty_fyi/providers/services_provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/container/tabs/service_tab/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final servicesNotifierProvider =
    StateNotifierProvider.autoDispose<ServicesNotifier, ServicesState>(
        (ref) => ServicesNotifier(ServicesProviderEnum.READALL, null));

class ServicesTab extends ConsumerWidget {
  final int serviceToFocus = -1;
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(servicesNotifierProvider);
    return ProviderListener(
        onChange: (context, state) {
          if (state is ServicesError)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              duration: Duration(minutes: 2),
              action: SnackBarAction(
                label: "refresh",
                onPressed: () => {
                  context.read(servicesNotifierProvider.notifier).getServices()
                },
              ),
            ));
        },
        provider: servicesNotifierProvider,
        child: Stack(
          children: <Widget>[
            Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      // colorStyles['blue'],
                      colorStyles['cream']!,
                      colorStyles['cream']!,
                    ]))),
            Container(
                height: double.infinity,
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      children: [
                        state is ServicesLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : state is ServicesLoaded
                                ? state.services.length == 0
                                    ? Row(children: [
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: AddNewServiceCard(
                                              refresh: () => context
                                                  .read(servicesNotifierProvider
                                                      .notifier)
                                                  .getServices(),
                                            )),
                                      ])
                                    : ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            ((state.services.length / 2) + 1)
                                                .floor(),
                                        itemBuilder: (context, index) {
                                          return index == 0
                                              ? Row(
                                                  children: [
                                                    AddNewServiceCard(
                                                        refresh: () => context
                                                            .read(
                                                                servicesNotifierProvider
                                                                    .notifier)
                                                            .getServices()),
                                                    ServiceCard(
                                                        serviceModel: state
                                                            .services[index],
                                                        refresh: () => context
                                                            .read(
                                                                servicesNotifierProvider
                                                                    .notifier)
                                                            .getServices()),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    ServiceCard(
                                                      refresh: () => context
                                                          .read(
                                                              servicesNotifierProvider
                                                                  .notifier)
                                                          .getServices(),
                                                      serviceModel:
                                                          state.services[
                                                              (index * 2) - 1],
                                                    ),
                                                    (index * 2) <
                                                            state
                                                                .services.length
                                                        ? ServiceCard(
                                                            refresh: () => context
                                                                .read(servicesNotifierProvider
                                                                    .notifier)
                                                                .getServices(),
                                                            serviceModel:
                                                                state.services[
                                                                    index * 2],
                                                          )
                                                        : Expanded(
                                                            child: AspectRatio(
                                                            aspectRatio: 4 / 5,
                                                          ))
                                                  ],
                                                );
                                        })
                                : Container(),
                      ],
                    ))),
          ],
        ));
  }
}
