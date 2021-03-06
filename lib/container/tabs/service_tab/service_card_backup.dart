import 'dart:io';

import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatefulWidget {
  final ServiceModel serviceModel;
  final VoidCallback? viewService;
  final serviceCardTapped;
  final int? serviceToFocus;
  const ServiceCard({
    Key? key,
    required this.serviceModel,
    this.viewService,
    this.serviceCardTapped,
    this.serviceToFocus,
  }) : super(key: key);
  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late final File serviceImage;
  @override
  void initState() {
    super.initState();
    serviceImage = widget.serviceModel.imageSrc as File;
  }

  final List<Color?> defaultColourList = [Colors.white, colorStyles['cream']];
  final List<Color?> activeColorList = [
    colorStyles['blue'],
    colorStyles['blue']
  ];
  bool cardIsFocused = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AspectRatio(
      aspectRatio: 4 / 5,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/view-service", arguments: {
              'serviceId': widget.serviceModel.id,
            });
          },
          child: Card(
            elevation: /*widget.serviceToFocus == widget.serviceModel.id ? 15 :*/ 5,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: false //widget.serviceToFocus == widget.serviceModel.id
                    ? [activeColorList[0]!, activeColorList[1]!]
                    : [defaultColourList[0]!, defaultColourList[1]!],
              )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: CircleAvatar(
                        backgroundColor: colorStyles['light_purple'],
                        radius: MediaQuery.of(context).size.height / 13,
                        backgroundImage: serviceImage.existsSync()
                            ? FileImage(serviceImage)
                            : null),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            new Border.all(color: Colors.white, width: 3.0)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.serviceModel.serviceName as String,
                    style: TextStyle(
                        color:
                            false //widget.serviceToFocus == widget.serviceModel.id
                                ? Colors.white
                                : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "",
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class AddNewServiceCard extends StatefulWidget {
  final VoidCallback? refresh;
  final bool constrained;
  const AddNewServiceCard({Key? key, this.refresh, this.constrained = false})
      : super(key: key);

  @override
  _AddNewServiceCardState createState() => _AddNewServiceCardState();
}

class _AddNewServiceCardState extends State<AddNewServiceCard> {
  @override
  Widget build(BuildContext context) {
    return !widget.constrained
        ? Expanded(
            child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/add-service");
                },
                child: Card(
                  elevation: 5,
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: false
                                  ? [
                                      colorStyles['light_purple']!,
                                      colorStyles['green']!,
                                      colorStyles['blue']!,
                                      colorStyles['dark_purple']!,
                                    ]
                                  : [
                                      colorStyles['green']!,
                                      colorStyles['blue']!,
                                      colorStyles['dark_purple']!,
                                      colorStyles['light_purple']!,
                                    ])),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "Add your next service",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'OpenSans',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      )),
                ),
              ),
            ),
          ))
        : Container(
            child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, "/add-service");
                },
                child: Card(
                  elevation: 10,
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: false
                                  ? [
                                      colorStyles['light_purple']!,
                                      colorStyles['green']!,
                                      colorStyles['blue']!,
                                      colorStyles['dark_purple']!,
                                    ]
                                  : [
                                      colorStyles['green']!,
                                      colorStyles['blue']!,
                                      colorStyles['dark_purple']!,
                                      colorStyles['light_purple']!,
                                    ])),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "Add your next service",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'OpenSans',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      )),
                ),
              ),
            ),
          ));
  }
}
