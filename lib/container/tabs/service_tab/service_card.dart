import 'dart:io';

import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatefulWidget {
  final ServiceModel serviceModel;
  final int? numberOfSessions;
  final VoidCallback? viewService;
  final serviceCardTapped;
  final int? serviceToFocus;
  final refresh;
  const ServiceCard(
      {Key? key,
      required this.serviceModel,
      this.numberOfSessions,
      this.viewService,
      this.serviceCardTapped,
      this.serviceToFocus,
      this.refresh})
      : super(key: key);
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
    colorStyles['green'],
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
          onTapUp: (tapDownDetails) {
            // widget.serviceCardTapped(widget.serviceModel.id);
            Future.delayed(Duration(milliseconds: 200)).then((value) {
              Navigator.pushNamed(context, "/view-service", arguments: {
                'sessionModel': widget.serviceModel,
              }).then((value) => widget.refresh());
            });
          },
          child: Card(
            elevation:
                widget.serviceToFocus == widget.serviceModel.id ? 15 : 10,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: widget.serviceToFocus == widget.serviceModel.id
                    ? [activeColorList[0]!, activeColorList[1]!]
                    : [defaultColourList[0]!, defaultColourList[1]!],
              )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: CircleAvatar(
                        radius: 45,
                        backgroundImage: serviceImage.existsSync()
                            ? FileImage(serviceImage)
                            : null),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            new Border.all(color: Colors.white, width: 2.0)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.serviceModel.serviceName as String,
                    style: TextStyle(
                        color: widget.serviceToFocus == widget.serviceModel.id
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
                  widget.numberOfSessions == 1
                      ? Text(
                          "${widget.numberOfSessions.toString()} session",
                          style: TextStyle(
                            color:
                                widget.serviceToFocus == widget.serviceModel.id
                                    ? Colors.white
                                    : Colors.grey.shade300,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        )
                      : Text(
                          "${widget.numberOfSessions.toString()} sessions",
                          style: TextStyle(
                            color:
                                widget.serviceToFocus == widget.serviceModel.id
                                    ? Colors.white
                                    : Colors.grey.shade300,
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
  bool transitionToNextPage = false;
  @override
  Widget build(BuildContext context) {
    if (transitionToNextPage) {}
    return !widget.constrained
        ? Expanded(
            child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    transitionToNextPage = !transitionToNextPage;
                  });
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.pushNamed(context, "/add-service")
                        .then((value) => widget.refresh!());
                  });
                },
                child: Card(
                  elevation: 10,
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: transitionToNextPage
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
            height: 200,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      transitionToNextPage = !transitionToNextPage;
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.pushNamed(context, "/add-service")
                          .then((value) => widget.refresh!());
                    });
                  },
                  child: Card(
                    elevation: 10,
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: transitionToNextPage
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
