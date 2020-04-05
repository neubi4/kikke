import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/perfdata.dart';

class PerfDataController {
  IcingaObject iobject;

  String rawPerfData;

  List<PerfData> perfData = [];

  PerfDataController(IcingaObject iobject) {
    this.iobject = iobject;
    this.rawPerfData = iobject.getData('perfdata');
    this.parse();
  }

  void parse() {
    if(this.rawPerfData == '') {
      return;
    }
    List<String> splitted = this.rawPerfData.split(' ');
    splitted.forEach((element) {
      this.perfData.add(PerfData(iobject, element));
    });
  }

  List<Widget> getDetailPerfDataWidgets(BuildContext context) {
    List<Widget> widgets = [];

    this.perfData.forEach((perfData) {
      widgets.add(perfData.getDetailWidgetListTile(context));
      widgets.add(Divider(height: 0.0,));
    });

    return widgets;
  }
}
