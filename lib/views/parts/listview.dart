import 'package:flutter/material.dart';
import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/models/downtime.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/views/parts/list.dart';
import 'package:queries/collections.dart';

class IcingaObjectListView extends StatefulWidget {
  const IcingaObjectListView({
    Key key,
    @required this.controller,
    this.listAll = false,
    this.search = "",
    this.selectMode = false,
    this.selected,
    this.longClicked,
  }) : super(key: key);

  final IcingaObjectController controller;
  final bool listAll;
  final String search;
  final bool selectMode;
  final Collection<IcingaObject> selected;
  final ValueChanged<IcingaObject> longClicked;

  @override
  createState() => new IcingaObjectListViewState();
}

class IcingaObjectListViewState extends State<IcingaObjectListView> {
  Future<void> _refresh() async {
    print('refreshing...');
    await widget.controller.fetch();
    setState(() {});
  }

  void _handleClick(IcingaObject iobject) async {
    if(this.widget.selectMode) {
      this._handleLongClick(iobject);
    } else {
      if(iobject is Downtime) {
        IcingaObject parent = iobject.getParent();
        if(parent != null) {
          Navigator.pushNamed(context, '/detail', arguments: parent);
        }
        return;
      }
      Navigator.pushNamed(context, '/detail', arguments: iobject);
    }
  }

  void _handleLongClick(IcingaObject iobject) {
    this.widget.longClicked(iobject);
  }

  Future getListFuture() {
    if (widget.listAll) {
      if (widget.search == "") {
        return widget.controller.getAll();
      } else {
        return widget.controller.getAllSearch(widget.search);
      }
    } else {
      return widget.controller.getAllWithProblems();
    }
  }

  Widget getEmptyList() {
    if (widget.search != "") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Icon(
            Icons.warning,
            color: Colors.blue[500],
            size: 50,
          ),
          Center(child: new Text("Nothing Found!")),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Icon(
          Icons.check,
          color: Colors.green[800],
          size: 50,
        ),
        Center(child: new Text("Liste leer!")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    //DowntimesController a = getIt.get<DowntimesController>();
    //a.getAllSync();

    return FutureBuilder<Collection<IcingaObject>>(
      future: this.getListFuture(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return InkWell(
              onTap: () {
                _refresh();
              },
              child: this.getEmptyList(),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Scrollbar(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  height: 0.0,
                ),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  bool _selected = false;
                  if(this.widget.selected != null) {
                    _selected = this.widget.selected.contains(snapshot.data[index]);
                  }
                  if(snapshot.data[index] is Downtime) {
                    return ListRowDowntime(
                        iobject: snapshot.data[index], clicked: _handleClick, longClicked: _handleLongClick, selected: _selected);
                  } else {
                    return ListRow(
                        iobject: snapshot.data[index], clicked: _handleClick, longClicked: _handleLongClick, selected: _selected);
                  }
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
              Text("${snapshot.error}"),
            ],
          );
        }

        return new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}
