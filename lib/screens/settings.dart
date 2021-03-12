import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kikke/controller/appsettings.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/models/instancesettings.dart';
import 'package:kikke/screens/drawermenu.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import 'drawermenu.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings settings;
  String proxy;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
            setState(() {});
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
    final appState = Provider.of<AppState>(context);
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
              Card(
                child: Form(
                  key: this._formKey,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          "Settings",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(
                        height: 0.0,
                      ),
                      ListTile(
                        leading: Text("Dark Mode"),
                        title: DropdownButton(
                          value: this.settings.themeMode,
                          items: [
                            DropdownMenuItem(
                              child: Text("System"),
                              value: ThemeMode.system,
                            ),
                            DropdownMenuItem(
                              child: Text("Dark"),
                              value: ThemeMode.dark,
                            ),
                            DropdownMenuItem(
                              child: Text("Light"),
                              value: ThemeMode.light,
                            ),
                          ],
                          onChanged: (value) {
                            appState.updateTheme(value);
                            setState(() {
                              this.settings.saveThemeMode(value);
                            });
                          },
                        ),
                      ),
                      Divider(
                        height: 0.0,
                      ),
                      ListTile(
                        leading: Text("HTTP Proxy"),
                        title: Container(
                          width: 100,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'http://proxy:8080',
                              labelText: 'HTTP Proxy',
                            ),
                            initialValue: this.settings.proxy,
                            validator: (value) {
                              if(value == '') {
                                return null;
                              }

                              try {
                                Uri uri = Uri.parse(value);
                                if(uri.host == '') {
                                  return 'URL is missing a host';
                                }
                                if(uri.port == 0) {
                                  return 'URL is missing a port';
                                }
                              } on FormatException catch (e) {
                                return 'Proxy is not an uri';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              this.proxy = value;
                            },
                          ),
                        ),
                      ),
                      Divider(
                        height: 0.0,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(this._formKey.currentState.validate()) {
                                this._formKey.currentState.save();

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                        title: Text("Saving"),
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              CircularProgressIndicator(),
                                            ],
                                          )
                                        ],
                                      );
                                    });

                                await this.settings.saveProxy(this.proxy);
                                Navigator.of(context).pop();

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Saving"),
                                      actions: [
                                        TextButton(onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();

                                          Navigator.pushReplacementNamed(context, '/');
                                        }, child: Text('Ok'))
                                      ],
                                      content: Text("Settings Saved"),
                                    );
                                  }
                                );
                              }
                            },
                            child: Text("Save")
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
