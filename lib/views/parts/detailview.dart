import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kikke/controller/hostcontroller.dart';
import 'package:kikke/controller/instancecontroller.dart';
import 'package:kikke/controller/perfdatacontroller.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/controller/servicecontroller.dart';
import 'package:kikke/models/host.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';
import 'package:kikke/views/parts/list.dart';
import 'package:queries/collections.dart';

class IcingaDetailView extends StatefulWidget {
  const IcingaDetailView({
    Key key,
    @required this.iobject,
  }): super(key: key);

  final IcingaObject iobject;

  @override
  createState() => new IcingaDetailViewState();
}

class IcingaDetailViewState extends State<IcingaDetailView> {
  InstanceController controller;
  ServiceController serviceController = getIt.get<ServiceController>();
  HostController hostController = getIt.get<HostController>();

  Future<void> _refresh() async {
    print('refreshing...');
    List<Future> futures = [];
    futures.add(this.serviceController.fetch());
    futures.add(this.hostController.fetch());
    await Future.wait(futures);
    setState(() {});
  }

  List<Widget> getPerfData(BuildContext context, IcingaObject iobject) {
    PerfDataController p = PerfDataController(iobject);
    if(p.perfData.length < 1) {
      return [];
    }

    if(p.perfData.length > 30) {
      return [
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("${p.perfData.length} Performance Data", style: TextStyle(fontWeight: FontWeight.bold),),
                onTap: () {
                  Navigator.pushNamed(context, '/detail/perfdata', arguments: iobject);
                },
              ),
            ],
          ),
        ),
      ];
    }

    return [
      Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("Performance Data", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Divider(height: 0.0,),
            ...p.getDetailPerfDataWidgets(context),
          ],
        ),
      ),
    ];
  }

  String _validateComment(String value) {
    if (value.length < 3) {
      return 'The Comment must be at least 1 character.';
    }

    return null;
  }

  List<Widget> getDetails(BuildContext context, IcingaObject iobject) {
    return [
      Card(
        child: Column(
          children: <Widget>[
            if (iobject is Service)
              icingaObjectHeaderListTile(iobject.host),
            icingaObjectHeaderListTile(iobject),
            Divider(
              height: 0.0,
            ),
            IcingaCheckListTile(iobject: iobject),
            Divider(
              height: 0.0,
            ),
            ListTile(
              title: Text(iobject.getData('check_command')),
              subtitle: Text('Check Command'),
            ),
            Divider(
              height: 0.0,
            ),
            ListTile(
              title: Text("${iobject.getStateSinceDate()}, ${iobject.getDateFieldSince(iobject.lastStateChangeField)}"),
              subtitle: Text('Last state Change'),
            ),
            Divider(
              height: 0.0,
            ),
            ListTile(
              title: Text("Acknowledge"),
              leading: Icon(Icons.check),
              onTap: () async {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
                      String comment = "";
                      bool notify = true;
                      bool persistent = false;
                      bool sticky = false;
                      int expire = 0;

                      bool isLoading = false;
                      String error = "";

                      return StatefulBuilder(
                        builder: (context, setState) {
                          if(isLoading) {
                            return AlertDialog(
                              title: Text("Acknowledge ${this.widget.iobject.name}"),
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
                            title: Text("Acknowledge ${this.widget.iobject.name}"),
                            content: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    if (error != "")
                                      Text(error),
                                    TextFormField(
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                        hintText: 'Comment',
                                        labelText: 'Comment',
                                      ),
                                      validator: this._validateComment,
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
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Acknowledge"),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      await iobject.instance.acknowledge(iobject, comment, notify: notify, expire: expire, sticky: sticky, persistent: persistent);
                                      Navigator.of(context).pop();
                                    } on Exception catch(e) {
                                      setState(() {
                                        isLoading = false;
                                        error = e.toString();
                                      });
                                    }
                                  }
                                },
                              ),
                              FlatButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    });
              },
            ),
          ],
        ),
      )
    ];
  }

  Widget showInstance(IcingaObject iobject) {
    if (iobject is Service) {
      return null;
    }
    return SizedBox(
      width: 50,
      child: AutoSizeText(
        iobject.getInstanceName(),
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(color: Colors.black.withOpacity(0.4)),
        maxFontSize: 12,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget showStatus(IcingaObject iobject) {
    if (iobject.getData('acknowledged') == "1") {
      return Icon(Icons.check, color: Colors.green, size: 17.0);
    } else if (iobject.getData('in_downtime') == "1") {
      return Icon(Icons.access_time, color: Colors.black45, size: 17.0);
    }
  }

  Container icingaObjectHeaderListTile(IcingaObject iobject) {
    return Container(
      decoration: new BoxDecoration(
        color: iobject.getData('handled') == "0" ? iobject.getBackgroundColor(context) : null,
        border: Border(
          left: BorderSide(width: 5, color: iobject.getBorderColor()),
        ),
      ),
      child: ListTile(
          onTap: () {
            this._handleClick(iobject);
          },
          title: Text(iobject.getDisplayName(),
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(iobject.getName()),
          trailing: this.showStatus(iobject),
          leading: Container(
            width: 50.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  iobject.getStateText(),
                  maxLines: 1,
                ),
                Text(
                  "${iobject.getStateSince()}",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 10
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
      ),
    );
  }

  List<Widget> getServices(BuildContext context, Host host) {
    List<Widget> desc = List();
    List<Widget> l = List();
    Collection<Service> services = this.serviceController.getAllForHost(host);
    Collection<Service> servicesOk = this.serviceController.getWithStatus(host, "0");
    Collection<Service> servicesWarning = this.serviceController.getWithStatus(host, "1");
    Collection<Service> servicesCritical = this.serviceController.getWithStatus(host, "2");
    Collection<Service> servicesUnknown = this.serviceController.getWithStatus(host, "3");

    desc.add(
        ListTile(
          title: Text("${services.length} Services (${servicesOk.length} Ok, ${servicesWarning.length} Warning, ${servicesCritical.length} Critical, ${servicesUnknown.length} Unkown)"),
        )
    );
    desc.add(Divider(
      height: 0.0,
    ));

    for (var i = 0; i < services.length; i++) {
      l.add(ListRowNoHostname(iobject: services[i], clicked: _handleClick, selected: false,));
      if (i < (services.length - 1)) {
        l.add(Divider(height: 0.0,));
      }
    }

    return [
      Card(
          child: Column(
            children: desc + l,
          )
      )
    ];
  }

  void _handleClick(IcingaObject iobject) {
    if (iobject != widget.iobject) {
      Navigator.pushNamed(context, '/detail', arguments: iobject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
          body: Container(
            child: Scrollbar(
              child: ListView(
                children: <Widget>[
                  ...getDetails(context, widget.iobject),
                  ...getPerfData(context, widget.iobject),
                  if (widget.iobject is Host)
                    ...getServices(context, widget.iobject),
                ],
              ),
            ),
          )
      ),
    );
  }
}

class IcingaCheckListTile extends StatefulWidget {
  const IcingaCheckListTile({
    Key key,
    @required this.iobject,
  }): super(key: key);

  final IcingaObject iobject;

  @override
  createState() => new IcingaCheckListTileState();
}

class IcingaCheckListTileState extends State<IcingaCheckListTile> {
  Timer timer;

  String getNextCheck() {
    return "Next check ${widget.iobject.getDateFieldSince('next_update')}";
  }

  @override
  void deactivate() {
    if (this.timer != null) {
      this.timer.cancel();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.iobject.getData('next_update') != "" && (this.timer == null || !this.timer.isActive)) {
      this.timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        if (timer.isActive && this.mounted) {
          setState(() {

          });
        } else {
          this.timer.cancel();
        }
      });
    }

    return ListTile(
      title: Text(widget.iobject.getData(widget.iobject.outputField)),
      subtitle: (widget.iobject.getData('next_update') == "") ? Text(widget.iobject.getData('check_command')) : Text(this.getNextCheck()),
    );
  }
}
