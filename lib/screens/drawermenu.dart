import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the Drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 75,
              child: DrawerHeader(
                child: Text('Kikke', style: TextStyle(color: Colors.white),),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              title: Text('Problems'),
              selected: ModalRoute.of(context).settings.name == '/' ,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              title: Text('Hosts'),
              selected: ModalRoute.of(context).settings.name == '/lists/hosts' ,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/lists/hosts');
              },
            ),
            ListTile(
              title: Text('Services'),
              selected: ModalRoute.of(context).settings.name == '/lists/services' ,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/lists/services');
              },
            ),
            ListTile(
              title: Text('Downtimes'),
              selected: ModalRoute.of(context).settings.name == '/lists/downtimes' ,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/lists/downtimes');
              },
            ),
            ListTile(
              title: Text('Settings'),
              selected: ModalRoute.of(context).settings.name == '/settings' ,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              title: Text('Imprint'),
              selected: ModalRoute.of(context).settings.name == '/imprint' ,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/imprint');
              },
            ),
          ],
        ),
      ),
    );
  }
}
