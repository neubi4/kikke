import 'package:flutter/material.dart';
import 'package:mobilemon/time/timeago.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobilemon/controller/appsettings.dart';
import 'package:mobilemon/controller/icingacontroller.dart';
import 'package:mobilemon/models/icingaobject.dart';
import 'package:mobilemon/controller/servicecontroller.dart';
import 'package:mobilemon/screens/drawermenu.dart';
import 'package:mobilemon/screens/login.dart';
import 'package:mobilemon/views/parts/detailview.dart';
import 'package:mobilemon/views/parts/listview.dart';

import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/controller/service_locator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppSettings appSettings = new AppSettings();
  await appSettings.loadData();

  var initRoute = '/';
  if (appSettings.icingaUrl == null && appSettings.username == null && appSettings.password == null) {
    initRoute = '/settings';
  }

  ServiceController serviceController = new ServiceController(appSettings: appSettings);
  HostController hostController = new HostController(appSettings: appSettings, serviceController: serviceController);

  serviceController.setHostController(hostController);

  getIt.registerSingleton<AppSettings>(appSettings);
  getIt.registerSingleton<ServiceController>(serviceController);
  getIt.registerSingleton<HostController>(hostController);

  timeago.setLocaleMessages('en', EnMessages());
  timeago.setLocaleMessages('de', DeMessages());

  runApp(MaterialApp(
    // Start the app with the "/" named route. In our case, the app will start
    // on the FirstScreen Widget
    initialRoute: initRoute,
    routes: {
      // When we navigate to the "/" route, build the FirstScreen Widget
      '/': (context) => MobileMonHomepage(),
      '/lists/hosts': (context) => MobileMonList(controller: getIt.get<HostController>(), title: "Hosts",),
      '/lists/services': (context) => MobileMonList(controller: getIt.get<ServiceController>(), title: "Services",),
      '/detail': (context) => MobileMonDetail(),
      '/settings': (context) => SettingsPage(),
    },
    title: 'MobileMon',
  ));
}

class MobileMonHomepage extends StatelessWidget {
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
              new IcingaObjectListView(controller: getIt.get<ServiceController>()),
              new IcingaObjectListView(controller: getIt.get<HostController>()),
            ],
          ),
        ),
        drawer: DrawerMenu(),
      ),
    );
  }
}

class MobileMonList extends StatelessWidget {
  const MobileMonList({
    Key key,
    @required this.controller,
    @required this.title,
  }): super(key: key);

  final IcingaObjectController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return  new Scaffold(
      appBar: new AppBar(
        title: new Text(this.title),
      ),
      body: new Center(
        child: IcingaObjectListView(controller: this.controller, listAll: true,)
        ),
      drawer: DrawerMenu(),
    );
  }
}

class MobileMonDetail extends StatefulWidget {
  const MobileMonDetail({
    Key key
  }): super(key: key);

  @override
  createState() => new MobileMonDetailState();
}

class MobileMonDetailState extends State<MobileMonDetail> {
  @override
  Widget build(BuildContext context) {
    IcingaObject iobject = ModalRoute.of(context).settings.arguments;

    return  new Scaffold(
      appBar: new AppBar(
        title: new Text(iobject.getName()),
      ),
      body: new Center(
          child: IcingaDetailView(iobject: iobject)
      ),
    );
  }
}
