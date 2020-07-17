import 'package:flutter/material.dart';
import 'package:kikke/app_state.dart';
import 'package:kikke/controller/instancecontroller.dart';
import 'package:kikke/screens/settings.dart';
import 'package:kikke/time/timeago.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:kikke/controller/appsettings.dart';
import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/controller/servicecontroller.dart';
import 'package:kikke/screens/drawermenu.dart';
import 'package:kikke/screens/login.dart';
import 'package:kikke/views/parts/detailview.dart';
import 'package:kikke/views/parts/listview.dart';

import 'package:kikke/controller/hostcontroller.dart';
import 'package:kikke/controller/service_locator.dart';

import 'controller/perfdatacontroller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppSettings appSettings = new AppSettings();
  await appSettings.loadDataFromProvider();

  var initRoute = '/';
  if (appSettings.instances.instances.length < 1) {
    initRoute = '/settings';
  }

  InstanceController controller = new InstanceController.fromSettings(appSettings);

  ServiceController serviceController = new ServiceController(controller: controller);
  HostController hostController = new HostController(controller: controller);

  getIt.registerSingleton<InstanceController>(controller);
  getIt.registerSingleton<AppSettings>(appSettings);
  getIt.registerSingleton<ServiceController>(serviceController);
  getIt.registerSingleton<HostController>(hostController);

  timeago.setLocaleMessages('en', EnMessages());
  timeago.setLocaleMessages('de', DeMessages());

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (context) => AppState(appSettings.themeMode),
      child: KikkeApp(initRoute),
    ),
  );
}

class KikkeApp extends StatelessWidget {
  String initRoute;

  KikkeApp(this.initRoute);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          // Start the app with the "/" named route. In our case, the app will start
          // on the FirstScreen Widget
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.lightBlueAccent,
          ),
          themeMode: appState.themeMode,
          initialRoute: initRoute,
          routes: {
            // When we navigate to the "/" route, build the FirstScreen Widget
            '/': (context) => AppHomePage(),
            '/lists/hosts': (context) => AppListPage(controller: getIt.get<HostController>(), title: "Hosts",),
            '/lists/services': (context) => AppListPage(controller: getIt.get<ServiceController>(), title: "Services",),
            '/detail': (context) => AppDetailPage(),
            '/detail/perfdata': (context) => AppDetailPerfdataPage(),
            '/settings': (context) => SettingsScreen(),
            '/settings/account': (context) => SettingsPage(),
            '/imprint': (context) => ImprintPage(),
          },
          title: 'Kikke',
        );
      },
    );
  }
}

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

class ImprintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imprint'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: <Widget>[
              Text("Martin Neubert\n"
                  "Ludwig-Hartmann-Straße 8\n"
                  "01277 Dresden\n"
                  "\n"
                  "apps@slashserver.net"),
            ],
          ),
        ),
      ),
      drawer: DrawerMenu(),
    );
  }
}

class AppListPage extends StatefulWidget {
  const AppListPage({
    Key key,
    @required this.controller,
    @required this.title,
  }): super(key: key);

  final IcingaObjectController controller;
  final String title;

  @override
  createState() => new AppListPageState();
}

class AppListPageState extends State<AppListPage> {
  final TextEditingController _filter = new TextEditingController();
  String searchText = "";
  Icon searchIcon = Icon(Icons.search, color: Colors.white);
  Widget searchField;
  Widget appBarText;

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    this.searchField =  Form(
      child: new TextField(
        controller: _filter,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
        autofocus: true,
        decoration: new InputDecoration(
          prefixIcon: new Icon(Icons.search, color: Colors.white,),
          hintText: 'Search...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }


  AppListPageState() {
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
        this.appBarText = this.searchField;
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

class AppDetailPage extends StatefulWidget {
  const AppDetailPage({
    Key key
  }): super(key: key);

  @override
  createState() => new AppDetailPageState();
}

class AppDetailPageState extends State<AppDetailPage> {
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

class AppDetailPerfdataPage extends StatefulWidget {
  const AppDetailPerfdataPage({
    Key key
  }): super(key: key);

  @override
  createState() => new AppDetailPerfdataPageState();
}

class AppDetailPerfdataPageState extends State<AppDetailPerfdataPage> {
  @override
  Widget build(BuildContext context) {
    IcingaObject iobject = ModalRoute.of(context).settings.arguments;
    PerfDataController p = PerfDataController(iobject);

    return  new Scaffold(
      appBar: new AppBar(
        title: new Text(iobject.getName()),
      ),
      body: new Center(
          child: Scaffold(
            body: Container(
              child: Scrollbar(
                child: ListView.separated(
                  itemCount: p.perfData.length,
                  itemBuilder: (context, index) {
                    return p.perfData[index].getDetailWidgetListTile(context);
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 0.0,);
                  },
                ),
              ),
            ),
          ),
      ),
    );
  }
}
