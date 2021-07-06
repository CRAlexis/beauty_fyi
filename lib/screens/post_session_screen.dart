import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/media/grid_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class PostSessionScreen extends StatefulWidget {
  final args;
  const PostSessionScreen({Key? key, this.args}) : super(key: key);

  @override
  _PostSessionScreenState createState() => _PostSessionScreenState();
}

class _PostSessionScreenState extends State<PostSessionScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.args['session_data']);
    return Scaffold(
        backgroundColor: colorStyles['cream']!,
        appBar: CustomAppBar(
            focused: true,
            transparent: false,
            titleText: "Beauty-FYI",
            leftIconClicked: () => Navigator.of(context).pop(),
            leftIcon: Icons.arrow_back,
            showMenuIcon: false,
            menuOptions: ['delete'],
            menuIconClicked: (value) {
              switch (value) {
                case 'delete':
              }
            },
            automaticallyImplyLeading: false),
        body: TabBarView(controller: tabController, children: [
          GridMedia(images: widget.args['service_media']),
          SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.all(15),
            child: Text(
              (widget.args['session_data'] as SessionModel).notes as String,
              style: TextStyle(fontFamily: 'OpenSans', fontSize: 16),
            ),
          ))
        ]),
        bottomNavigationBar: ColoredTabBar(
          colorStyles['cream']!,
          TabBar(
            controller: tabController,
            labelPadding: EdgeInsets.all(2),
            tabs: [
              Tab(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.image),
                  Text("Gallery"),
                ],
              )),
              Tab(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.edit),
                  Text("Notes"),
                ],
              )),
            ],
            labelColor: colorStyles['green'],
            unselectedLabelColor: Colors.grey.shade300,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(3.0),
            indicatorColor: Colors.transparent,
          ),
        ));
  }
}

class ColoredTabBar extends ColoredBox implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar) : super(color: color, child: tabBar);

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;
}
