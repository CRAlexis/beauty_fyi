import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';

class PostSessionScreen extends StatefulWidget {
  final args;
  PostSessionScreen({this.args});
  @override
  _PostSessionScreenState createState() => _PostSessionScreenState();
}

class _PostSessionScreenState extends State<PostSessionScreen> {
  late SessionModel sessionModel;
  ScrollController _pageScrollController = ScrollController();
  double elevation = 0;
  @override
  void initState() {
    super.initState();
    sessionModel = widget.args['sessionModel'];
    _pageScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _pageScrollController.dispose();
    } catch (e) {}
  }

  _scrollListener() {
    if (_pageScrollController.position.pixels > 50) {
      setState(() {
        elevation = 20;
      });
    } else {
      setState(() {
        elevation = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: CustomAppBar(
          focused: true,
          transparent: false,
          elevation: elevation,
          dark: false,
          titleText: "",
          centerTitle: true,
          leftIcon: Icons.arrow_back,
          showMenuIcon: false,
          leftIconClicked: () {
            Navigator.pop(context);
          },
          automaticallyImplyLeading: false),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
              controller: _pageScrollController,
              child: Container(height: 1500, child: Text("my body")))),
    );
  }
}
