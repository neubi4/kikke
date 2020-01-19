import 'package:flutter/material.dart';
import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/views/parts/list.dart';
import 'package:queries/collections.dart';

class IcingaObjectListView extends StatefulWidget {
  const IcingaObjectListView({
    Key key,
    @required this.controller,
    this.listAll = false,
    this.search = "",
  }): super(key: key);

  final IcingaObjectController controller;
  final bool listAll;
  final String search;

  @override
  createState() => new IcingaObjectListViewState();
}

class IcingaObjectListViewState extends State<IcingaObjectListView> {
  Future<void> _refresh() async {
    print('refreshing...');
    await widget.controller.fetch();
    setState(() {});
  }

  void _handleClick(IcingaObject iobject) {
    Navigator.pushNamed(context, '/detail', arguments: iobject);
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
        children: <Widget>[
          new Icon(
            Icons.warning,
            color: Colors.blue[500],
            size: 50,
          ),
          new Text("Nothing Found!"),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Icon(
          Icons.check,
          color: Colors.green[800],
          size: 50,
        ),
        new Text("Liste leer!"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListRow(iobject: snapshot.data[index], clicked: _handleClick);
              },
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
