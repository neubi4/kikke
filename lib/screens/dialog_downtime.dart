import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';

class DowntimeDialog {
  static String getTitle(List<IcingaObject> iobjects) {
    if(iobjects.length == 1) {
      if(iobjects[0] is Service) {
        Service iobject = iobjects[0] as Service;
        return "Downtime for ${iobject.host.getName()}:${iobjects[0].getName()}";
      }
      return "Downtime for ${iobjects[0].getName()}";
    }

    return "Downtime for ${iobjects.length} Objects";
  }

  static String getObjectNames(List<IcingaObject> iobjects) {
    List<String> names = [];

    iobjects.forEach((iobject) {
      if(iobject is Service) {
        names.add("${iobject.host.getName()}:${iobject.getName()}");
      } else {
        names.add(iobject.getName());
      }
    });

    return names.join("\n");
  }

  static String _validateComment(String value) {
    if (value.length < 1) {
      return 'The Comment must be at least 1 character.';
    }

    return null;
  }

  static Future showRemoveDialog(BuildContext context, StateSetter setState, List<IcingaObject> iobjects) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          bool isLoading = false;

          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text("Remove ${DowntimeDialog.getTitle(iobjects)}"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );

    for(int i = 0; i < iobjects.length; i++) {
      await iobjects[i].instance.removeDowntime(iobjects[i]);
    }
    Navigator.of(context).pop();
  }

  static Future show(BuildContext context, StateSetter setState, List<IcingaObject> iobjects, {callback}) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
          String comment = "";
          DateTime fromTime = DateTime.now();
          DateTime toTime = DateTime.now().add(Duration(hours: 1));

          bool isLoading = false;
          String error = "";

          return StatefulBuilder(
            builder: (context, setState) {
              if(isLoading) {
                return AlertDialog(
                  title: Text(DowntimeDialog.getTitle(iobjects)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }

              return AlertDialog(
                title: Text(DowntimeDialog.getTitle(iobjects)),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (error != "")
                          SelectableText(error, style: TextStyle(color: Colors.red),),
                        if (iobjects.length > 1)
                          Align(child: Text(DowntimeDialog.getObjectNames(iobjects),), alignment: Alignment.topLeft,),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: new InputDecoration(
                            hintText: 'Comment',
                            labelText: 'Comment',
                          ),
                          validator: DowntimeDialog._validateComment,
                          initialValue: comment,
                          onSaved: (String value) {
                            comment = value;
                          },
                        ),
                        Row(
                          children: [
                            Text("Start Time"),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: RaisedButton(
                                child: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(fromTime)),
                                onPressed: () async {
                                  fromTime = await showDatePicker(context: context, initialDate: fromTime, firstDate: DateTime.now(), lastDate: DateTime(2030));
                                  TimeOfDay time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(fromTime));
                                  fromTime = DateTime(fromTime.year, fromTime.month, fromTime.day, time.hour, time.minute);
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("End Time"),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: RaisedButton(
                                child: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(toTime)),
                                onPressed: () async {
                                  toTime = await showDatePicker(context: context, initialDate: toTime, firstDate: DateTime.now(), lastDate: DateTime(2030));
                                  TimeOfDay time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(toTime));
                                  toTime = DateTime(toTime.year, toTime.month, toTime.day, time.hour, time.minute);
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Schedule Downtime"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        setState(() {
                          isLoading = true;
                        });

                        List<String> errors = [];

                        for(int i = 0; i < iobjects.length; i++) {
                          try {
                            await iobjects[i].instance.scheduleDowmtime(iobjects[i], comment, fromTime, toTime);
                          } on Exception catch(e) {
                            errors.add(e.toString());
                          }
                        }

                        if(errors.length > 0) {
                          setState(() {
                            isLoading = false;
                            error = errors.join("; ");
                          });
                        } else {
                          Navigator.of(context).pop();
                          if(callback != null) {
                            callback();
                          }
                        }
                      }
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}
