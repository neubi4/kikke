import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validate/validate.dart';

class LoginData {
  String url = '';
  String username = '';
  String password = '';

  SharedPreferences prefs;

  static LoginData _instance;

  factory LoginData() {
    if(_instance == null) {
      _instance = LoginData._internal();
    }

    return _instance;
  }

  LoginData._internal();

  void loadFromSettings() async {
    prefs = await SharedPreferences.getInstance();
    url = prefs.getString('url');
    username = prefs.getString('username');
    password = prefs.getString('password');
  }

  Future save() async {
    await prefs.setString('url', url);
    await prefs.setString('username', username);
    await prefs.setString('password', password);
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

      print('Printing the login data.');
      print('Url: ${_data.url}');
      print('Username: ${_data.username}');
      print('Password: ${_data.password}');

      await _data.save();
    }
  }

  @override
  Widget build(BuildContext context) {
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
}
