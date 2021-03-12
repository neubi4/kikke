import 'dart:collection';

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

    this.rawPerfData = this.rawPerfData.replaceAll("'", "");
    this.rawPerfData = this.rawPerfData.replaceAll("  ", " ");

    PerfDataSet perfDataSet = PerfDataSet(this.rawPerfData);

    List<String> splitted = perfDataSet.getPerfData();
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

class PerfDataSet {
  String rawPerfData;
  List<String> perfData = [];

  int parserPos = 0;

  PerfDataSet(this.rawPerfData);

  List<String> getPerfData() {
    this.rawPerfData = this.rawPerfData.trim();
    if(this.rawPerfData == '') {
      return [];
    }

    while(this.parserPos < this.rawPerfData.length) {
      String label = this.readUntil('=');
      this.parserPos++;
      String data = this.readUntil(' ');

      this.perfData.add("${label}=${data}");
    }

    return this.perfData;
  }

  String readUntil(String stopChar) {
    int start = this.parserPos;
    while(this.parserPos < this.rawPerfData.length && this.rawPerfData[this.parserPos] != stopChar) {
      this.parserPos++;
    }

    return this.rawPerfData.substring(start, this.parserPos);
  }
}
