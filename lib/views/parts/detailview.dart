import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kikke/controller/downtimecontroller.dart';
import 'package:kikke/controller/hostcontroller.dart';
import 'package:kikke/controller/instancecontroller.dart';
import 'package:kikke/controller/perfdatacontroller.dart';
import 'package:kikke/controller/service_locator.dart';
import 'package:kikke/controller/servicecontroller.dart';
import 'package:kikke/models/downtime.dart';
import 'package:kikke/models/host.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';
import 'package:kikke/screens/dialog_ack.dart';
import 'package:kikke/screens/dialog_downtime.dart';
import 'package:kikke/views/parts/list.dart';
import 'package:url_launcher/url_launcher.dart';

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
  DowntimeController downtimeController = getIt.get<DowntimeController>();

  List<Downtime> downtimes;

  @override
  initState() {
    super.initState();
    this.refreshDowntimes();
  }

  void refreshDowntimes() {
    downtimeController.getForObject(widget.iobject).then((value) {
      setState(() {
        this.downtimes = value;
      });
    });
  }

  Future<void> _refresh() async {
    print('refreshing...');
    List<Future> futures = [];
    futures.add(this.serviceController.fetch());
    futures.add(this.hostController.fetch());
    futures.add(this.downtimeController.fetch());
    await Future.wait(futures);
    setState(() {
      this.refreshDowntimes();
    });
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

  List<Widget> getDowntimes(BuildContext context, IcingaObject iobject) {
    List<Widget> l = [];

    if(this.downtimes == null) {
      l.add(
        Divider(
          height: 0.0,
        ),
      );
      l.add(
        ListTile(
          title: Text('Downtimes'),
          leading: CircularProgressIndicator(),
        ),
      );
    } else {
      this.downtimes.toList().forEach((downtime) {
        l.add(
          Divider(
            height: 0.0,
          ),
        );
        l.add(
          ListTile(
            title: Text("Downtime ${downtime.getDescription(context)}"),
            trailing: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () async {
                await DowntimeDialog.showRemoveDialog(context, setState, [downtime]);
                await this._refresh();
              },
            ),
          ),
        );
      });
    }

    return l;
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
              title: SelectableText(iobject.getData('check_command')),
              subtitle: Text('Check Command'),
            ),
            Divider(
              height: 0.0,
            ),
            ListTile(
              title: SelectableText("${iobject.getStateSinceDate()}, ${iobject.getDateFieldSince(iobject.lastStateChangeField)}"),
              subtitle: Text('Last state Change'),
            ),
            Divider(height: 0.0,),
            ListTile(
              title: Text('Open in Webinterface'),
              leading: Icon(Icons.open_in_new),
              onTap: () async {
                final Uri _url = Uri.parse(iobject.getWebUrl());
                launchUrl(_url);
              },
            ),
            if (iobject.getData('acknowledged') == "0" && iobject.getState() != 0)
              Divider(
                height: 0.0,
              ),
            if (iobject.getData('acknowledged') == "0" && iobject.getState() != 0)
              ListTile(
                title: Text("Acknowledge"),
                leading: Icon(Icons.check),
                onTap: () async {
                  AckDialog.show(context, setState, [iobject], callback: _refresh);
                },
              ),
            // Currently not working, post to remove ack only reschedules check
            /*if (iobject.getData('acknowledged') == "1" && iobject.getState() != 0)
              ListTile(
                title: Text("Remove Acknowledgement"),
                leading: Icon(Icons.check),
                onTap: () async {
                  AckDialog.showRemoveDialog(context, setState, [iobject]);
                },
              ),*/
            Divider(
              height: 0.0,
            ),
            ListTile(
              title: Text("Schedule Downtime"),
              leading: Icon(Icons.access_time),
              onTap: () async {
                await DowntimeDialog.show(context, setState, [iobject], callback: _refresh);
                await this._refresh();
              },
            ),
            ...getDowntimes(context, iobject),
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

    return null;
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
          title: SelectableText(iobject.getDisplayName(),
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: SelectableText(iobject.getName()),
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
                SelectableText(
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
    List<Widget> desc = [];
    List<Widget> l = [];
    List<Service> services = this.serviceController.getAllForHost(host);
    List<Service> servicesOk = this.serviceController.getWithStatus(host, "0");
    List<Service> servicesWarning = this.serviceController.getWithStatus(host, "1");
    List<Service> servicesCritical = this.serviceController.getWithStatus(host, "2");
    List<Service> servicesUnknown = this.serviceController.getWithStatus(host, "3");

    desc.add(
        ListTile(
          title: SelectableText("${services.length} Services (${servicesOk.length} Ok, ${servicesWarning.length} Warning, ${servicesCritical.length} Critical, ${servicesUnknown.length} Unkown)"),
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
      title: SelectableText(widget.iobject.getData(widget.iobject.outputField)),
      subtitle: (widget.iobject.getData('next_update') == "") ? SelectableText(widget.iobject.getData('check_command')) : SelectableText(this.getNextCheck()),
    );
  }
}
