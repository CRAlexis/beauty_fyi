import 'dart:io';

import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class ImageAndNameCard extends StatelessWidget {
  final String serviceName;
  final File serviceImage;
  final onEdit;
  final onDelete;
  ImageAndNameCard(
      {this.serviceName, this.serviceImage, this.onEdit, this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          serviceImage,
                        ),
                      )),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: Text(
                          serviceName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                              fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(5.0)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )),
                                    backgroundColor: MaterialStateProperty.all(
                                        colorStyles['green'])),
                                onPressed: () => onEdit(),
                                // color: Colors.white,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(
                                      width: 0,
                                    ),
                                    Text(
                                      "",
                                      style: textStyles['button_label_white'],
                                    ),
                                  ],
                                )),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(5.0)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.red.shade300)),
                                onPressed: () => onDelete(),
                                // color: Colors.white,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(
                                      width: 0,
                                    ),
                                    Text(
                                      "",
                                      style: textStyles['button_label_white'],
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ))
            ],
          )),
    );
  }
}
