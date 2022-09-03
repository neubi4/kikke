import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kikke/controller/appsettings.dart';
import 'package:kikke/controller/instancecontroller.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/models/instancesettings.dart';
import 'package:uuid/uuid.dart';

class LoginData {
  String name;
  String url;
  String username;
  String password;

  InstanceSetting _instanceSetting;

  AppSettings settings;

  LoginData(InstanceSetting instanceSetting) {
    this.settings = getIt.get<AppSettings>();
    this._instanceSetting = instanceSetting;
  }

  Future save(BuildContext context) async {
    try {
      await this.settings.checkData(this._instanceSetting.url,
          this._instanceSetting.username, this._instanceSetting.password);
      await this.settings.saveData(
          this._instanceSetting.id,
          this._instanceSetting.name,
          this._instanceSetting.url,
          this._instanceSetting.username,
          this._instanceSetting.password);

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    } on Exception catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: SelectableText(error.toString()),
              actions: <Widget>[
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  LoginData _data;
  InstanceSetting _instanceSetting = new InstanceSetting(Uuid().v4(), '', '', '', '');

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    this._data = LoginData(this._instanceSetting);
  }

  String _validateName(String value) {
    if (value.length < 3) {
      return 'The Name must be at least 3 characters.';
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
    this._data._instanceSetting = this._instanceSetting;
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text("Logging in"),
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

      await _data.save(context);
    }
  }

  Widget buildForm(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    InstanceSetting setting = ModalRoute.of(context).settings.arguments;
    if (setting != null) {
      this._instanceSetting = setting;
    }

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
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      hintText: 'Instance Name',
                      labelText: 'Enter your Instnance Name'),
                  initialValue: this._instanceSetting.name,
                  validator: this._validateName,
                  onSaved: (String value) {
                    this._instanceSetting.name = value;
                  },
                ),
                new TextFormField(
                  keyboardType: TextInputType.url,
                  // Use email input type for emails.
                  decoration: new InputDecoration(
                      hintText: 'https://your-icinga.com',
                      labelText: 'Icingaweb2 URL'),
                  initialValue: this._instanceSetting.url,
                  validator: this._validateUrl,
                  onSaved: (String value) {
                    this._instanceSetting.url = value;
                  },
                ),
                new TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      hintText: 'Username', labelText: 'Enter your Username'),
                  initialValue: this._instanceSetting.username,
                  validator: this._validateName,
                  onSaved: (String value) {
                    this._instanceSetting.username = value;
                  },
                ),
                new TextFormField(
                  obscureText: true, // Use secure text for passwords.
                  decoration: new InputDecoration(
                      hintText: 'Password', labelText: 'Enter your password'),
                  validator: this._validatePassword,
                  initialValue: this._instanceSetting.password,
                  onSaved: (String value) {
                    this._instanceSetting.password = value;
                  },
                ),
                new Container(
                  width: screenSize.width,
                  child: new ElevatedButton(
                    child: new Text(
                      'Login',
                      style: new TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: this.submit,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.buildForm(context);
  }
}
