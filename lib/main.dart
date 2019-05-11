import 'package:flutter/material.dart';
import 'package:mobilemon/controller/appsettings.dart';
import 'package:mobilemon/controller/icingacontroller.dart';
import 'package:mobilemon/models/host.dart';
import 'package:mobilemon/models/icingaobject.dart';
import 'package:mobilemon/controller/servicecontroller.dart';
import 'package:mobilemon/models/service.dart';
import 'package:mobilemon/screens/drawermenu.dart';
import 'package:mobilemon/screens/login.dart';
import 'package:mobilemon/views/parts/list.dart';
import 'package:queries/collections.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/controller/service_locator.dart';


void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var host = prefs.getString('host');
  var username = prefs.getString('username');
  var password = prefs.getString('password');

  var initRoute = '/';
  if (host == null && username == null && password == null) {
    //initRoute = '/login';
  }

  AppSettings appSettings = new AppSettings();
  ServiceController serviceController = new ServiceController(appSettings: appSettings);
  HostController hostController = new HostController(appSettings: appSettings, serviceController: serviceController);

  serviceController.setHostController(hostController);

  getIt.registerSingleton<AppSettings>(appSettings);
  getIt.registerSingleton<ServiceController>(serviceController);
  getIt.registerSingleton<HostController>(hostController);

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

class IcingaObjectListView extends StatefulWidget {
  const IcingaObjectListView({
    Key key,
    @required this.controller,
    this.listAll = false,
  }): super(key: key);

  final IcingaObjectController controller;
  final bool listAll;

  @override
  createState() => new IcingaObjectListViewState();
}

class IcingaObjectListViewState extends State<IcingaObjectListView> {
  Future<void> _refresh() async {
    print('refreshing...');
    await widget.controller.fetch();
    setState(() {});
  }

  void _handleClick(IcingaObject iobject) {
    Navigator.pushNamed(context, '/detail', arguments: iobject);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Collection<IcingaObject>>(
      future: widget.listAll ? widget.controller.getAll() : widget.controller.getAllWithProblems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.check,
                  color: Colors.green[800],
                  size: 50,
                ),
                new Text("Alles OK!"),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListRow(iobject: snapshot.data[index], clicked: _handleClick);
              },
            ),
          );
        } else if (snapshot.hasError) {
          return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
              Text("${snapshot.error}"),
            ],
          );
        }

        return new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}

class IcingaDetailView extends StatefulWidget {
  const IcingaDetailView({
    Key key,
    @required this.iobject,
  }): super(key: key);

  final IcingaObject iobject;

  @override
  createState() => new IcingaDetailViewState();
}

class IcingaDetailViewState extends State<IcingaDetailView> {
  List<Widget> getDetails(BuildContext context, IcingaObject iobject) {
    return [
      ListRow(iobject: iobject, clicked: _handleClick),
      Card(
          child: ListTile(
            subtitle: Text("Name"),
            title: Text(iobject.getName()),
          )
      ),
      Card(
          child: ListTile(
            subtitle: Text("Outout"),
            title: Text(iobject.getData(iobject.outputField)),
          )
      ),
      Card(
          child: ListTile(
            subtitle: Text("State Since"),
            title: Text("${iobject.getStateSince()} (${iobject.getStateSinceDate()})"),
          )
      ),
      Card(
          child: ListTile(
            subtitle: Text("Check Command"),
            title: Text(iobject.getData('check_command')),
          )
      ),
    ];
  }

  List<Widget> getServices(BuildContext context, Host host) {
    List<Widget> l =  List();
    ServiceController controller = getIt.get<ServiceController>();
    Collection<Service> services = controller.getAllForHost(host);
    print(services);

    for (var i = 0; i < services.length; i++) {
      l.add(ListRowNoHostname(iobject: services[i], clicked: _handleClick));
    }

    return l;
  }

  void _handleClick(IcingaObject iobject) {
    if (iobject != widget.iobject) {
      Navigator.pushNamed(context, '/detail', arguments: iobject);
    }
  }

  @override
  Widget build(BuildContext context) {
    Service service;
    if (widget.iobject is Service) {
      service = widget.iobject;
    }
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            ...getDetails(context, widget.iobject),
            if (widget.iobject is Service)
              ...getDetails(context, service.host),
            if (widget.iobject is Host)
              ...getServices(context, widget.iobject),
          ],
        ),
      )
    );
  }
}
