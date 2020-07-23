import 'package:flutter/material.dart';
import 'package:kikke/screens/drawermenu.dart';

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
