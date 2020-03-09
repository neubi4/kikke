import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kikke/controller/appsettings.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/models/instancesettings.dart';
import 'package:kikke/screens/drawermenu.dart';

import 'drawermenu.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings settings;

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    this.settings = getIt.get<AppSettings>();
  }

  List<Widget> getAccounts(InstanceSetting setting) {
    return [
      ListTile(
        title: Text(setting.name),
        subtitle: Text(setting.url),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          tooltip: "Delete Instance ${setting.name}",
          onPressed: () async {
            await this.settings.delete(setting);
            setState(() {

            });
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/settings/account', arguments: setting).then((value) {
            if (this.settings.instances.instances.length < 2) {
              Navigator.popAndPushNamed(context, '/');
            } else {
              setState(() {

              });
            }
          });
        },
      ),
      Divider(
        height: 0.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      drawer: DrawerMenu(),
      body: Scrollbar(
        child: new Center(
          child: Column(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        "Accounts",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    for (var i = 0; i < this.settings.instances.instances.length; i++)
                      ...getAccounts(this.settings.instances.instances[i]),
                    ListTile(
                      title: Text(
                        "Add Account",
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings/account').then((value) {
                          if (this.settings.instances.instances.length < 2) {
                            Navigator.popAndPushNamed(context, '/');
                          } else {
                            setState(() {

                            });
                          }
                        });
                      },
                    ),
                    Divider(
                      height: 0.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
