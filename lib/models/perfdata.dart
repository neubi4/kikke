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

  final String conditionWarn = 'Warning';
  final String conditionCrit = 'Critical';
  final Map<String, int> stateMap = {
    'Warning': 1,
    'Critical': 2,
  };

  PerfData(IcingaObject iobject, String perfData) {
    this.iobject = iobject;

    List<String> splitName = perfData.split('=');
    this.name = splitName[0];

    List<String> splitData = splitName[1].split(';');
    int i = 0;
    splitData.forEach((element) {
      if (element == "") {
        i++;
        return;
      }
      switch (i) {
        case 0:
          //first data
          RegExp exp = new RegExp(r"([0-9]+(\.[0-9]+)?)(.*)?");
          RegExpMatch match = exp.firstMatch(element);
          this.value = double.parse(match.group(1));
          this.unit = match.group(3);
          break;
        case 1:
          this.warn = getRange(element, this.conditionWarn);
          break;
        case 2:
          this.crit = getRange(element, this.conditionCrit);
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

    if(this.warn != null && this.crit != null) {
      double warnMax = this.warn.getMax();
      double critMax = this.crit.getMax();
      if(warnMax != null && critMax != null) {
        if ((warnMax > critMax) || ( warnMax == 0.0 && critMax == 0.0)) {
          this.warn.setInverted();
          this.crit.setInverted();
        }
      }
    }

    if(this.unit == '%') {
      this.min = 0.0;
      this.max = 100.0;
    }
  }

  Range getRange(String rangeString, String conditionString) {
    if (rangeString.contains(':')) {
      return AdvancedRange(rangeString, conditionString);
    }

    return SimpleRange(rangeString, conditionString);
  }

  bool withBackgroupColor() {
    if ((this.warn != null && !this.warn.isInRange(this.value)) ||
        (this.crit != null && !this.crit.isInRange(this.value))) {
      return true;
    }
    return false;
  }

  int getState() {
    List<Range> conditions = [
      this.crit,
      this.warn,
    ];

    if(this.warn.isInverted) {
      conditions = List<Range>.from(conditions.reversed);
    }

    for(Range condition in conditions) {
      if(condition != null && !condition.isInRange(this.value)) {
        return this.stateMap[condition.conditionString];
      }
    }

    return 0;
  }

  PerfDataFormatter getFormatter() {
    if (this.unit != null) {
      switch (this.unit.toLowerCase()) {
        case "s":
          return DurationPerfDataFormatter(this);
          break;
        case "b":
        case "kb":
        case "mb":
        case "gb":
          return BytePerfDataFormatter(this);
          break;
      }
    }

    return PerfDataFormatter(this);
  }

  List<Widget> getDetails() {
    List<Widget> l = [];

    l.add(Text("Value: ${this.value}"));

    if (this.unit != null) {
      l.add(Text("Unit: ${this.unit}"));
    }

    if (this.warn != null) {
      l.add(Text("Warn: ${this.warn.rawRange}"));
    }

    if (this.crit != null) {
      l.add(Text("Crit: ${this.crit.rawRange}"));
    }

    if (this.min != null) {
      l.add(Text("Min: ${this.min}"));
    }

    if (this.max != null) {
      l.add(Text("Max: ${this.max}"));
    }

    return l;
  }

  Widget getDetailWidgetListTile(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: this.withBackgroupColor()
            ? this.iobject.getBackgroundColor(context, this.getState())
            : null,
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
                    TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}

abstract class Range {
  String rawRange;
  String conditionString;
  bool isInverted = false;

  Range(String rawRange, String conditionString) {
    this.rawRange = rawRange;
    this.conditionString = conditionString;
    this.parse();
  }

  void setInverted() {
    this.isInverted = true;
  }

  void parse() {}
  double getMax() {}

  bool isInRange(double value) {
    return false;
  }
}

class SimpleRange extends Range {
  double range;

  SimpleRange(String rawRange, String conditionString)
      : super(rawRange, conditionString);

  @override
  void parse() {
    this.range = double.parse(this.rawRange);
  }

  @override
  double getMax() {
    return this.range;
  }

  @override
  bool isInRange(double value) {
    if(this.isInverted) {
      return value > this.range;
    }
    return value < this.range;
  }
}

class AdvancedRange extends Range {
  double from;
  double to;

  AdvancedRange(String rawRange, String conditionString)
      : super(rawRange, conditionString);

  @override
  void parse() {
    if(this.rawRange.substring(0, 1) == '@') {
      this.setInverted();
      this.rawRange = this.rawRange.substring(1);
    }
    List<String> split = this.rawRange.split(':');
    switch(split[0]) {
      case '':
        this.from = 0.0;
        break;
      case '~':
        this.from = null;
        break;
      default:
        this.from = double.parse(split[0]);
        break;
    }

    if (split.length > 1) {
      if (split[1] != "") {
        this.to = double.parse(split[1]);
      }
    }
  }

  @override
  bool isInRange(double value) {
    if (this.from != null) {
      if(this.isInverted) {
        if (value > this.from) {
          return false;
        }
      }
      if (value < this.from) {
        return false;
      }
    }

    if (this.to != null) {
      if(this.isInverted) {
        if (value < this.to) {
          return false;
        }
      }
      if (value > this.to) {
        return false;
      }
    }

    return true;
  }

  @override
  double getMax() {
    return this.to;
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
    if (perfData.max != null) {
      percentage = " (${getPercentage().toStringAsFixed(2)}%)";
    }
    return "${perfData.name} $value ${(unit != null) ? unit : ""}$percentage";
  }

  double getPercentage() {
    if (perfData.max == null) {
      return null;
    }
    return ((perfData.value / perfData.max) * 100);
  }

  Widget getProgessBarWidget(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
          child: LinearProgressIndicator(
            value: this.perfData.value / this.perfData.max,
            minHeight: 10,
            valueColor: AlwaysStoppedAnimation<Color>(
                this.perfData.iobject.getBorderColor()),
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class SubtitledPerfDataFormatter extends PerfDataFormatter {
  SubtitledPerfDataFormatter(PerfData perfData) : super(perfData);

  @override
  Widget getSubTitle() {
    return Text(
        "${perfData.value.toString()} ${(perfData.unit != null) ? perfData.unit : ""}");
  }
}

class DurationPerfDataFormatter extends SubtitledPerfDataFormatter {
  DurationPerfDataFormatter(PerfData perfData) : super(perfData);

  String formatTime(double s) {
    String ret = "";

    Duration days = Duration(milliseconds: (s * Duration.millisecondsPerSecond).toInt());
    Duration hours = days - Duration(days: days.inDays);
    Duration minutes = days - Duration(hours: days.inHours);
    Duration seconds = days - Duration(minutes: days.inMinutes);

    if (seconds.inSeconds < 1) {
      ret = "${days.inMilliseconds}ms";
    } else {
      ret = "${seconds.inSeconds}s";
    }

    if (minutes.inMinutes > 0) {
      ret = "${minutes.inMinutes}m " + ret;
    }

    if (hours.inHours > 0) {
      ret = "${hours.inHours}h " + ret;
    }

    if (days.inDays > 0) {
      ret = "${days.inDays}d " + ret;
    }

    return ret;
  }

  @override
  Widget getTitle() {
    String formatedTime = formatTime(perfData.value);

    if (formatedTime == null) {
      return Text(getDefaultText(perfData.value.toString(), perfData.unit));
    }

    if (this.perfData.max != null) {
      return this.getProgessBarWidget("${perfData.name} $formatedTime");
    }

    return Text("${perfData.name} $formatedTime");
  }
}

class BytePerfDataFormatter extends SubtitledPerfDataFormatter {
  BytePerfDataFormatter(PerfData perfData) : super(perfData);

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = [
      "B",
      "KiB",
      "MiB",
      "GiB",
      "TiB",
      "PiB",
      "EiB",
      "ZiB",
      "YiB"
    ];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  double getCorrectValue([double v]) {
    double value = perfData.value;
    if (v != null) {
      value = v;
    }

    switch (this.perfData.unit.toLowerCase()) {
      case 'kb':
        value = value * 1024;
        break;
      case 'mb':
        value = value * 1024 * 1024;
        break;
      case 'gb':
        value = value * 1024 * 1024 * 1024;
        break;
    }
    return value;
  }

  @override
  Widget getTitle() {
    double value = this.getCorrectValue();

    if (this.perfData.max != null) {
      return this.getProgessBarWidget(
          getDefaultText(formatBytes(value.toInt(), 2), null));
    }

    return Text(getDefaultText(formatBytes(value.toInt(), 2), null));
  }

  @override
  Widget getSubTitle() {
    List<Range> conditions = [
      this.perfData.crit,
      this.perfData.warn,
    ];

    if(this.perfData.warn != null && this.perfData.warn.isInverted) {
      conditions = List<Range>.from(conditions.reversed);
    }

    String text = "Ok";

    for (Range condition in conditions) {
      if (condition != null && !condition.isInRange(this.perfData.value)) {
        switch (condition.runtimeType) {
          case SimpleRange:
            text =
                "${condition.conditionString} ${formatBytes(getCorrectValue().toInt(), 2)} > ${formatBytes(getCorrectValue((condition as SimpleRange).range).toInt(), 2)}";
            break;
          case AdvancedRange:
            text =
                "${condition.conditionString} ${formatBytes(getCorrectValue((condition as AdvancedRange).from).toInt(), 2)} > ${formatBytes(getCorrectValue().toInt(), 2)} < ${formatBytes(getCorrectValue((condition as AdvancedRange).to).toInt(), 2)}";
            break;
          default:
            text = "${condition.conditionString}";
        }
        break;
      }
    }

    return Text(text);
  }
}
