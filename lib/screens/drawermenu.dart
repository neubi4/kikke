import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Problems'),
            selected: ModalRoute.of(context).settings.name == '/' ,
            onTap: () {
              Navigator.popAndPushNamed(context, '/');
            },
          ),
          ListTile(
            title: Text('Hosts'),
            selected: ModalRoute.of(context).settings.name == '/lists/hosts' ,
            onTap: () {
              Navigator.popAndPushNamed(context, '/lists/hosts');
            },
          ),
          ListTile(
            title: Text('Services'),
            selected: ModalRoute.of(context).settings.name == '/lists/services' ,
            onTap: () {
              Navigator.popAndPushNamed(context, '/lists/services');
            },
          ),
          ListTile(
            title: Text('Settings'),
            selected: ModalRoute.of(context).settings.name == '/settings' ,
            onTap: () {
              Navigator.popAndPushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
