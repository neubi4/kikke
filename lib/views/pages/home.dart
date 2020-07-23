import 'package:flutter/material.dart';
import 'package:kikke/controller/hostcontroller.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/controller/servicecontroller.dart';
import 'package:kikke/screens/drawermenu.dart';
import 'package:kikke/views/parts/listview.dart';

class AppHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Problems'),
          bottom: TabBar(
            tabs: [
              Tab(text: "Services"),
              Tab(text: "Hosts"),
            ],
          ),
        ),
        body: new Center(
          child: TabBarView(
            children: <Widget>[
              IcingaObjectListView(controller: getIt.get<ServiceController>()),
              IcingaObjectListView(controller: getIt.get<HostController>()),
            ],
          ),
        ),
        drawer: DrawerMenu(),
      ),
    );
  }
}
