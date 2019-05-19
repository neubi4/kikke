import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobilemon/controller/appsettings.dart';
import 'package:mobilemon/controller/hostcontroller.dart';
import 'package:mobilemon/controller/service_locator.dart';
import 'package:mobilemon/controller/servicecontroller.dart';

class LoginData {
  String url;
  String username;
  String password;

  AppSettings settings;

  LoginData() {
    this.settings = getIt.get<AppSettings>();
  }

  Future<bool> loadFromSettings() async {
    if (this.username == null && this.password == null && this.url == null) {
      await this.settings.loadData();
      this.url = this.settings.icingaUrl;
      this.username = this.settings.username;
      this.password = this.settings.password;
    }

    return true;
  }

  Future save(BuildContext context) async {
    try {
      await this.settings.checkData(this.url, this.username, this.password);
      await this.settings.saveData(this.url, this.username, this.password);

      ServiceController serviceController = getIt.get<ServiceController>();
      HostController hostController = getIt.get<HostController>();

      serviceController.reset();
      hostController.reset();

      await serviceController.checkUpdate();

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushNamed(context, '/');
    } on Exception catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(error.toString()),
            );
          }
      );
    }
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  LoginData _data = new LoginData();

  String _validateUsername(String value) {
    if (value.length < 3) {
      return 'The URL must be at least 8 characters.';
    }

    return null;
  }

  String _validatePassword(String value) {
    if (value.length < 3) {
      return 'The Password must be at least 8 characters.';
    }

    return null;
  }

  String _validateUrl(String value) {
    if (value.length < 3) {
      return 'The URL must be at least 8 characters.';
    }

    return null;
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Speichert'),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              )
            ],
          );
        }
      );

      await _data.save(context);
    }
  }

  Widget buildForm(BuildContext context) {
    final Size screenSize = MediaQuery
        .of(context)
        .size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[
                new TextFormField(
                  keyboardType: TextInputType.url,
                  // Use email input type for emails.
                  decoration: new InputDecoration(
                      hintText: 'https://your-icinga.com',
                      labelText: 'Icingaweb2 URL'
                  ),
                  initialValue: _data.url,
                  validator: this._validateUrl,
                  onSaved: (String value) {
                    this._data.url = value;
                  },
                ),
                new TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  // Use email input type for emails.
                  decoration: new InputDecoration(
                      hintText: 'Username',
                      labelText: 'Enter your password'
                  ),
                  initialValue: _data.username,
                  validator: this._validateUsername,
                  onSaved: (String value) {
                    this._data.username = value;
                  },
                ),
                new TextFormField(
                  obscureText: true, // Use secure text for passwords.
                  decoration: new InputDecoration(
                      hintText: 'Password',
                      labelText: 'Enter your password'
                  ),
                  validator: this._validatePassword,
                  onSaved: (String value) {
                    this._data.password = value;
                  },
                ),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Login',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                    onPressed: this.submit,
                    color: Colors.blue,
                  ),
                  margin: new EdgeInsets.only(
                      top: 20.0
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _data.loadFromSettings(),
        builder: (context, snapshot) {
        if (snapshot.hasData) {
          return this.buildForm(context);
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
      }
    );
  }
}
