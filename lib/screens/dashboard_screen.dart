import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/container/tabs/services_tab.dart';
import 'package:beauty_fyi/container/tabs/clients_tab.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
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
    return Scaffold(
        appBar: CustomAppBar(
            focused: true,
            transparent: false,
            titleText: "Beauty-FYI",
            leftIcon: null,
            showMenuIcon: true,
            menuOptions: ['settings'],
            menuIconClicked: (value) {
              switch (value) {
                case 'settings':
                  Navigator.of(context).pushNamed('/settings-screen');
                  break;
              }
            },
            leftIconClicked: () {},
            automaticallyImplyLeading: false),
        body: TabBarView(
            controller: tabController, children: [ServicesTab(), ClientsTab()]),
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
                  Icon(Icons.home),
                  Text("Services"),
                ],
              )),
              Tab(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.person),
                  Text("Clients"),
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
