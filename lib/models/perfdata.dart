import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kikke/models/icingaobject.dart';

class PerfData {
  IcingaObject iobject;
  String name;
  double value;
  String unit;
  Range warn;
  Range crit;
  double min;
  double max;

  PerfData(IcingaObject iobject, String perfData) {
    this.iobject = iobject;

    List<String> splitName = perfData.split('=');
    this.name = splitName[0];

    List<String> splitData = splitName[1].split(';');
    int i = 0;
    splitData.forEach((element) {
      if(element == "") {
        return;
      }
      switch(i) {
        case 0:
          //first data
          RegExp exp = new RegExp(r"([0-9]+(\.[0-9]+)?)(.*)?");
          RegExpMatch match = exp.firstMatch(element);
          this.value = double.parse(match.group(1));
          this.unit = match.group(3);
          break;
        case 1:
          this.warn = getRange(element);
          break;
        case 2:
          this.crit = getRange(element);
          break;
        case 3:
          this.min = double.parse(element);
          break;
        case 4:
          this.max = double.parse(element);
          break;
      }
      i++;
    });
  }

  Range getRange(String rangeString) {
    if(rangeString.contains(':')) {
      return AdvancedRange(rangeString);
    }

    return SimpleRange(rangeString);
  }

  Widget getDetailWidgetListTile(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: (!this.warn.isInRange(this.value) || !this.crit.isInRange(this.value)) ? this.iobject.getBackgroundColor(context): null,
      ),
      child: ListTile(
        title: Text("${this.name} ${this.value.toString()}${(this.unit != null) ? this.unit : ""}"),
      ),
    );
  }
}

abstract class Range {
  String rawRange;

  Range(String rawRange) {
    this.rawRange = rawRange;
    this.parse();
  }

  void parse() {}

  bool isInRange(double value) {
    return false;
  }
}

class SimpleRange extends Range {
  double range;
  SimpleRange(String rawRange): super(rawRange);

  @override
  void parse() {
    this.range = double.parse(this.rawRange);
  }

  @override
  bool isInRange(double value) {
    return value < this.range;
  }
}

class AdvancedRange extends Range {
  double from;
  double to;

  AdvancedRange(String rawRange): super(rawRange);

  @override
  void parse() {
    List<String> split = this.rawRange.split(':');
    if(split[0] != "") {
      this.from = double.parse(split[0]);
    }

    if(split.length > 1) {
      if(split[1] != "") {
        this.to = double.parse(split[1]);
      }
    }
  }

  @override
  bool isInRange(double value) {
    if(this.from != null) {
      if(value < this.from) {
        return false;
      }
    }

    if(this.to != null) {
      if(value > this.to) {
        return false;
      }
    }

    return true;
  }
}
