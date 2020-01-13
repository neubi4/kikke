import 'package:flutter/material.dart';
import 'package:mobilemon/controller/instancecontroller.dart';
import 'package:mobilemon/models/icingainstance.dart';
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

  IcingaInstance instance = new IcingaInstance('zed', appSettings.icingaUrl, appSettings.username, appSettings.password);
  InstanceController controller = new InstanceController();
  controller.addInstance(instance);

  ServiceController serviceController = new ServiceController(controller: controller);
  HostController hostController = new HostController(controller: controller);

  getIt.registerSingleton<InstanceController>(controller);
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

class MobileMonList extends StatefulWidget {
  const MobileMonList({
    Key key,
    @required this.controller,
    @required this.title,
  }): super(key: key);

  final IcingaObjectController controller;
  final String title;

  @override
  createState() => new MobileMonListState();
}

class MobileMonListState extends State<MobileMonList> {
  final TextEditingController _filter = new TextEditingController();
  String searchText = "";
  Icon searchIcon = Icon(Icons.search, color: Colors.white);
  Widget appBarText;

  MobileMonListState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          searchText = "";
        });
      } else {
        setState(() {
          searchText = _filter.text;
        });
      }
    });
  }

  Widget buildAppBar() {
    return AppBar(
      title: this.appBarText,
      actions: <Widget>[
        new IconButton(icon: this.searchIcon, onPressed: searchPressed),
      ],
    );
  }

  void searchPressed() {
    setState(() {
      if (this.searchIcon.icon == Icons.search) {
        this.searchIcon = new Icon(Icons.close, color: Colors.white);
        this.appBarText = new TextField(
          controller: _filter,
          style: TextStyle(color: Colors.white, fontSize: 18.0),
          autofocus: true,
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white,),
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
        );
      } else {
        this._filter.text = "";
        this.searchText = "";
        this.searchIcon = new Icon(Icons.search, color: Colors.white);
        this.appBarText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.appBarText == null) {
      this.appBarText = Text(widget.title);
    }

    return  new Scaffold(
      appBar: this.buildAppBar(),
      body: new Center(
          child: IcingaObjectListView(controller: widget.controller, listAll: true, search: this.searchText,)
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
