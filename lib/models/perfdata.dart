import 'dart:math';

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

  bool withBackgroupColor() {
    if((this.warn != null && !this.warn.isInRange(this.value)) || (this.crit != null && !this.crit.isInRange(this.value))) {
      return true;
    }
    return false;
  }

  PerfDataFormatter getFormatter() {
    if(this.unit != null) {
      switch(this.unit.toLowerCase()) {
        case "s":
          return DurationPerfDataFormatter(this);
          break;
        case "b":
          return BytePerfDataFormatter(this);
          break;
      }
    }

    return PerfDataFormatter(this);
  }

  List<Widget> getDetails() {
    List<Widget> l = [];

    l.add(Text("Value: ${this.value}"));

    if(this.unit != null) {
      l.add(Text("Unit: ${this.unit}"));
    }

    if(this.warn != null) {
      l.add(Text("Warn: ${this.warn.rawRange}"));
    }

    if(this.crit != null) {
      l.add(Text("Crit: ${this.crit.rawRange}"));
    }

    if(this.min != null) {
      l.add(Text("Min: ${this.min}"));
    }

    if(this.max != null) {
      l.add(Text("Max: ${this.max}"));
    }

    return l;
  }

  Widget getDetailWidgetListTile(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: this.withBackgroupColor() ? this.iobject.getBackgroundColor(context): null,
      ),
      child: ListTile(
        title: this.getFormatter().getTitle(),
        subtitle: this.getFormatter().getSubTitle(),
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(this.name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: this.getDetails(),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          );
        },
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

class PerfDataFormatter {
  PerfData perfData;

  PerfDataFormatter(this.perfData);

  Widget getTitle() {
    return Text(getDefaultText(perfData.value.toString(), perfData.unit));
  }

  Widget getSubTitle() {
    return null;
  }

  String getDefaultText(String value, String unit) {
    String percentage = "";
    if(perfData.max != null) {
      percentage = " (${getPercentage().toStringAsFixed(2)}%)";
    }
    return "${perfData.name} $value ${(unit != null) ? unit : ""}$percentage";
  }

  double getPercentage() {
    if(perfData.max == null) {
      return null;
    }
    return ((perfData.value / perfData.max) * 100);
  }
}

class SubtitledPerfDataFormatter extends PerfDataFormatter {
  SubtitledPerfDataFormatter(PerfData perfData): super(perfData);

  @override
  Widget getSubTitle() {
    return Text("${perfData.value.toString()} ${(perfData.unit != null) ? perfData.unit : ""}");
  }
}

class DurationPerfDataFormatter extends SubtitledPerfDataFormatter {
  DurationPerfDataFormatter(PerfData perfData): super(perfData);

  @override
  Widget getTitle() {
    String ret = "";
    Duration days = Duration(seconds: perfData.value.toInt());
    Duration hours = days - Duration(days: days.inDays);
    Duration minutes = days - Duration(hours: days.inHours);
    Duration seconds = days - Duration(minutes: days.inMinutes);

    if(seconds.inSeconds < 1) {
      return Text(getDefaultText(perfData.value.toString(), perfData.unit));
    }

    ret = "${seconds.inSeconds}s";

    if(minutes.inMinutes > 0) {
      ret = "${minutes.inMinutes}m " + ret;
    }

    if(hours.inHours > 0) {
      ret = "${hours.inHours}h " + ret;
    }

    if(days.inDays > 0) {
      ret = "${days.inDays}d " + ret;
    }

    return Text("${perfData.name} $ret");
  }
}

class BytePerfDataFormatter extends SubtitledPerfDataFormatter {
  BytePerfDataFormatter(PerfData perfData) : super(perfData);

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  @override
  Widget getTitle() {
    double value = perfData.value;

    return Text(getDefaultText(formatBytes(value.toInt(), 2), null));
  }
}
