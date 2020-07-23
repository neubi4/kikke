import 'package:flutter/material.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/views/parts/detailview.dart';

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
