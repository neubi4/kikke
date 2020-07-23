import 'package:flutter/material.dart';
import 'package:kikke/controller/perfdatacontroller.dart';
import 'package:kikke/models/icingaobject.dart';

class AppDetailPerfdataPage extends StatefulWidget {
  const AppDetailPerfdataPage({
    Key key
  }): super(key: key);

  @override
  createState() => new AppDetailPerfdataPageState();
}

class AppDetailPerfdataPageState extends State<AppDetailPerfdataPage> {
  @override
  Widget build(BuildContext context) {
    IcingaObject iobject = ModalRoute.of(context).settings.arguments;
    PerfDataController p = PerfDataController(iobject);

    return  new Scaffold(
      appBar: new AppBar(
        title: new Text(iobject.getName()),
      ),
      body: new Center(
        child: Scaffold(
          body: Container(
            child: Scrollbar(
              child: ListView.separated(
                itemCount: p.perfData.length,
                itemBuilder: (context, index) {
                  return p.perfData[index].getDetailWidgetListTile(context);
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 0.0,);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
