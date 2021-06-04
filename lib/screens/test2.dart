import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "flutter providers",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(children: [
            SizedBox(
              height: 20,
            ),
            _buttonTemplate(
                color: Colors.blue,
                name: "Provider",
                navigate: "/provider",
                context: context),
            SizedBox(
              height: 20,
            ),
            _buttonTemplate(
                color: Colors.purple,
                name: "State Provider",
                navigate: "/state_provider",
                context: context),
            SizedBox(
              height: 20,
            ),
            _buttonTemplate(
                color: Colors.redAccent,
                name: "Stream Provider",
                navigate: "/stream_provider",
                context: context),
            SizedBox(
              height: 20,
            ),
            _buttonTemplate(
                color: Colors.orange,
                name: "Future Provider",
                navigate: "/future_provider",
                context: context),
            SizedBox(
              height: 20,
            ),
            _buttonTemplate(
                color: Colors.yellow,
                name: "Change notifier",
                navigate: "/change_notifier",
                context: context),
            SizedBox(
              height: 20,
            ),
            _buttonTemplate(
                color: Colors.green,
                name: "State notifier",
                navigate: "/state_notifier",
                context: context)
          ]),
        ));
  }
}

Widget _buttonTemplate(
    {required String name,
    required String navigate,
    required BuildContext context,
    required Color color}) {
  return TextButton(
    onPressed: () => Navigator.pushNamed(context, navigate),
    child: Text(
      name,
      style: TextStyle(
          fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        minimumSize: MaterialStateProperty.all(
            Size(MediaQuery.of(context).size.width - 100, 50))),
  );
}
