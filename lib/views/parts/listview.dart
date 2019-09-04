import 'package:flutter/material.dart';
import 'package:mobilemon/controller/icingacontroller.dart';
import 'package:mobilemon/models/icingaobject.dart';
import 'package:mobilemon/views/parts/list.dart';
import 'package:queries/collections.dart';

class IcingaObjectListView extends StatefulWidget {
  const IcingaObjectListView({
    Key key,
    @required this.controller,
    this.listAll = false,
  }): super(key: key);

  final IcingaObjectController controller;
  final bool listAll;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Collection<IcingaObject>>(
      future: widget.listAll ? widget.controller.getAll() : widget.controller.getAllWithProblems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return InkWell(
              onTap: () {
                _refresh();
              },
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(
                    Icons.check,
                    color: Colors.green[800],
                    size: 50,
                  ),
                  new Text("Liste leer!"),
                ],
              ),
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
