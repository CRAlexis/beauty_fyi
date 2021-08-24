import 'dart:io';

import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel serviceModel;
  final VoidCallback refresh;
  ServiceCard({
    required this.serviceModel,
    required this.refresh,
  });

  final List<Color?> defaultColourList = [Colors.white, colorStyles['cream']];
  final List<Color?> activeColorList = [
    colorStyles['blue'],
    colorStyles['blue']
  ];

  Widget build(BuildContext context) {
    final serviceImage = serviceModel.imageSrc as File;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/view-service", arguments: {
              'serviceId': serviceModel.id,
            }).then((value) => refresh());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Card(
                    elevation: 10,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                        backgroundColor: colorStyles['light_purple'],
                        radius: MediaQuery.of(context).size.height / 9.5,
                        backgroundImage: serviceImage.existsSync()
                            ? FileImage(serviceImage)
                            : null)),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(color: Colors.white, width: 3.0)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                serviceModel.serviceName as String,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNewServiceCard extends StatefulWidget {
  final VoidCallback refresh;
  const AddNewServiceCard({required this.refresh});

  @override
  _AddNewServiceCardState createState() => _AddNewServiceCardState();
}

class _AddNewServiceCardState extends State<AddNewServiceCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/add-service")
                .then((value) => widget.refresh());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  child: Card(
                      elevation: 10,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height / 9.5,
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 100,
                              ),
                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      colorStyles['light_purple']!,
                                      colorStyles['blue']!,
                                      colorStyles['dark_purple']!,
                                    ])),
                          )))),
              SizedBox(
                height: 5,
              ),
              Text(
                "",
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
