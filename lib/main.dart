import 'package:flutter/material.dart';
import 'package:mobilemon/screens/login.dart';
import 'package:queries/collections.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/controller/service_locator.dart';
import 'package:mobilemon/models/host.dart';

void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var host = prefs.getString('host');
  var username = prefs.getString('username');
  var password = prefs.getString('password');

  var initRoute = '/login';
  if (host == null && username == null && password == null) {
    initRoute = '/login';
  }

  getIt.registerSingleton<HostController>(new HostController());

  runApp(MaterialApp(
    // Start the app with the "/" named route. In our case, the app will start
    // on the FirstScreen Widget
    initialRoute: initRoute,
    routes: {
      // When we navigate to the "/" route, build the FirstScreen Widget
      '/': (context) => MobileMon(),
      '/login': (context) => LoginPage(),
    },
  ));
}

class MobileMon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MobileMon',
      home: DefaultTabController(
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
                new Text("not implemented"),
                new HostProblemListView(),
              ],
            ),
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the Drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: 100.0,
                  child: DrawerHeader(
                    child: Text('Drawer Header'),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Problems'),
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
                ListTile(
                  title: Text('Login'),
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HostProblemListView extends StatefulWidget {
  @override
  createState() => new HostProblemListViewState();
}

class HostProblemListViewState extends State<HostProblemListView> {
  HostController controller = getIt.get<HostController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Collection<Host>>(
      future: controller.getHosts(),
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
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return new Container(
                decoration: new BoxDecoration(
                  color: snapshot.data[index].getBackgroundColor(),
                ),
                child: new ListTile(
                  title: Text("${snapshot.data[index].getName()}"),
                  subtitle: Text(snapshot.data[index].getData("host_output")),
                  leading: snapshot.data[index].getIcon(),
                  onTap: () {
                    print("onTap ${snapshot.data[index].name}");
                  },
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();
      },
    );
  }
}
