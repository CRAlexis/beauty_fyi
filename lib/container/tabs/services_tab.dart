import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/container/tabs/service_tab/service_card.dart';
import 'package:flutter/material.dart';

class ServicesTab extends StatefulWidget {
  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  int serviceToFocus = 1;
  late Future<List<ServiceModel>> services;
  @override
  void initState() {
    super.initState();
    refreshFuture();
  }

  void refreshFuture() {
    services = fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              children: <Widget>[
                FutureBuilder(
                  future: services,
                  builder:
                      (context, AsyncSnapshot<List<ServiceModel>> services) {
                    if (services.connectionState == ConnectionState.none ||
                        !services.hasData ||
                        services.data?.length == 0) {
                      return AddNewServiceCard(
                        constrained: true,
                        refresh: () {
                          setState(() {});
                        },
                      );
                    }
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: ((services.data!.length / 2) + 1).floor(),
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Row(
                                  children: [
                                    AddNewServiceCard(refresh: () {
                                      setState(() {
                                        refreshFuture();
                                      });
                                    }),
                                    ServiceCard(
                                      serviceModel:
                                          services.data?[index] as ServiceModel,
                                      numberOfSessions: 18,
                                      serviceToFocus: serviceToFocus,
                                      serviceCardTapped: (serviceId) {
                                        setState(() {
                                          setServiceCardFocus(serviceId);
                                        });
                                      },
                                      refresh: () {
                                        refreshFuture();
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    ServiceCard(
                                      serviceModel:
                                          services.data?[index] as ServiceModel,
                                      numberOfSessions: 18,
                                      serviceToFocus: serviceToFocus,
                                      serviceCardTapped: (serviceId) {
                                        setState(() {
                                          setServiceCardFocus(serviceId);
                                        });
                                      },
                                      refresh: () {
                                        refreshFuture();
                                      },
                                    ),
                                    (index * 2) < services.data!.length
                                        ? ServiceCard(
                                            serviceModel: services.data?[index]
                                                as ServiceModel,
                                            numberOfSessions: 18,
                                            serviceToFocus: serviceToFocus,
                                            serviceCardTapped: (serviceId) {
                                              setState(() {
                                                setServiceCardFocus(serviceId);
                                              });
                                            },
                                            refresh: () {
                                              refreshFuture();
                                            },
                                          )
                                        : Expanded(
                                            child: AspectRatio(
                                            aspectRatio: 4 / 5,
                                          ))
                                  ],
                                );
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void setServiceCardFocus(serviceId) {
    serviceToFocus == serviceId
        ? serviceToFocus = 0
        : serviceToFocus = serviceId;
  }
}

Future<List<ServiceModel>> fetchServices() async {
  return await ServiceModel().readServices();
}
