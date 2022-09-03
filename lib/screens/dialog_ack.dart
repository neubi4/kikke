import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';

class AckDialog {
  static String getTitle(List<IcingaObject> iobjects) {
    if(iobjects.length == 1) {
      if(iobjects[0] is Service) {
        Service iobject = iobjects[0] as Service;
        return "Acknowledge ${iobject.host.getName()}:${iobjects[0].getName()}";
      }
      return "Acknowledge ${iobjects[0].getName()}";
    }

    return "Acknowledge ${iobjects.length} Objects";
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

  static void showRemoveDialog(BuildContext context, StateSetter setState, List<IcingaObject> iobjects) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Remove ${AckDialog.getTitle(iobjects)}"),
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
      await iobjects[i].instance.removeAcknowledge(iobjects[i]);
    }
    Navigator.of(context).pop();
  }

  static void show(BuildContext context, StateSetter setState, List<IcingaObject> iobjects, {callback}) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
          String comment = "";
          bool notify = true;
          bool persistent = false;
          bool sticky = false;
          bool expire = false;
          DateTime expireTime = DateTime.now();

          bool isLoading = false;
          String error = "";

          return StatefulBuilder(
            builder: (context, setState) {
              if(isLoading) {
                return AlertDialog(
                  title: Text(AckDialog.getTitle(iobjects)),
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
                title: Text(AckDialog.getTitle(iobjects)),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (error != "")
                          SelectableText(error, style: TextStyle(color: Colors.red),),
                        if (iobjects.length > 1)
                          Align(child: Text(AckDialog.getObjectNames(iobjects),), alignment: Alignment.topLeft,),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: new InputDecoration(
                            hintText: 'Comment',
                            labelText: 'Comment',
                          ),
                          validator: AckDialog._validateComment,
                          initialValue: comment,
                          onSaved: (String value) {
                            comment = value;
                          },
                        ),
                        Row(
                          children: [
                            Switch(
                              value: notify,
                              onChanged: (bool value) {
                                setState(() {
                                  notify = value;
                                });
                              },
                            ),
                            Text("Notify"),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: sticky,
                              onChanged: (bool value) {
                                setState(() {
                                  sticky = value;
                                });
                              },
                            ),
                            Text("Sticky"),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: persistent,
                              onChanged: (bool value) {
                                setState(() {
                                  persistent = value;
                                });
                              },
                            ),
                            Text("Persistend"),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: expire,
                              onChanged: (bool value) {
                                setState(() {
                                  expire = value;
                                });
                              },
                            ),
                            Text("Expire"),
                            if(expire)
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: ElevatedButton(
                                  child: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(expireTime)),
                                  onPressed: () async {
                                    expireTime = await showDatePicker(context: context, initialDate: expireTime, firstDate: DateTime.now(), lastDate: DateTime(2030));
                                    TimeOfDay time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(expireTime));
                                    expireTime = DateTime(expireTime.year, expireTime.month, expireTime.day, time.hour, time.minute);
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
                    child: Text("Acknowledge"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        setState(() {
                          isLoading = true;
                        });

                        List<String> errors = [];

                        for(int i = 0; i < iobjects.length; i++) {
                          try {
                            await iobjects[i].instance.acknowledge(iobjects[i], comment, notify: notify, expire: expire, expireTime: expireTime, sticky: sticky, persistent: persistent);
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
