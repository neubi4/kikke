import 'package:flutter/material.dart';
import 'package:kikke/controller/downtimecontroller.dart';
import 'package:kikke/controller/icingacontroller.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/screens/dialog_ack.dart';
import 'package:kikke/screens/dialog_downtime.dart';
import 'package:kikke/screens/drawermenu.dart';
import 'package:kikke/views/parts/listview.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({
    Key key,
    @required this.controller,
    @required this.title,
  }): super(key: key);

  final IcingaObjectController controller;
  final String title;

  @override
  createState() => new AppListPageState();
}

class AppListPageState extends State<AppListPage> {
  final TextEditingController _filter = new TextEditingController();
  String searchText = "";
  bool selectMode = false;
  List<IcingaObject> selected = [];
  Icon searchIcon = Icon(Icons.search, color: Colors.white);
  Widget searchField;
  Widget appBarText;

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    this.searchField =  Form(
      child: new TextField(
        controller: _filter,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
        autofocus: true,
        decoration: new InputDecoration(
          prefixIcon: new Icon(Icons.search, color: Colors.white,),
          hintText: 'Search...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  AppListPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          searchText = "";
        });
      } else {
        setState(() {
          searchText = _filter.text;
        });
      }
    });
  }

  Widget buildAppBar() {
    return AppBar(
      title: this.appBarText,
      actions: <Widget>[
        new IconButton(icon: this.searchIcon, onPressed: searchPressed),
      ],
    );
  }

  void searchPressed() {
    setState(() {
      if (this.searchIcon.icon == Icons.search) {
        this.searchIcon = new Icon(Icons.close, color: Colors.white);
        this.appBarText = this.searchField;
      } else {
        this._filter.text = "";
        this.searchText = "";
        this.searchIcon = new Icon(Icons.search, color: Colors.white);
        this.appBarText = null;
      }
    });
  }

  void _handleLongClick(IcingaObject iobject) {
    setState(() {
      if(this.selected.contains(iobject)) {
        this.selected.remove(iobject);

        if(this.selected.length == 0) {
          this.selectMode = false;
        }
      } else {
        this.selectMode = true;
        this.selected.add(iobject);
      }
    });
  }

  void reset() {
    setState(() {
      this.selectMode = false;
      this.selected.clear();
    });
  }

  Widget bottomNavBar(BuildContext context) {
    if (this.widget.controller is !DowntimeController) {
      return BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Acknowledge on ${this.selected.length} ${this.widget.controller.getType()}s",),
              leading: Icon(Icons.check),
              onTap: () {
                AckDialog.show(context, setState, this.selected.toList());
              },
            ),
            Divider(height: 0.0,),
            ListTile(
              title: Text("Set Downtime on ${this.selected.length} ${this.widget.controller.getType()}s",),
              leading: Icon(Icons.access_time),
              onTap: () {
                DowntimeDialog.show(context, setState, this.selected.toList());
              },
            ),
            Divider(height: 0.0,),
            ListTile(
              title: Text("Deselect ${this.selected.length} ${this.widget.controller.getType()}s",),
              leading: Icon(Icons.close),
              onTap: () {
                setState(() {
                  this.selectMode = false;
                  this.selected.clear();
                });
              },
            ),
          ],
        ),
      );
    }

    return BottomAppBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Delete ${this.selected.length} ${this.widget.controller.getType()}s",),
            leading: Icon(Icons.access_time),
            onTap: () async {
              await DowntimeDialog.showRemoveDialog(context, setState, this.selected.toList());
              await widget.controller.fetch();
              setState(() {
                this.selectMode = false;
                this.selected.clear();
              });
            },
          ),
          Divider(height: 0.0,),
          ListTile(
            title: Text("Deselect ${this.selected.length} ${this.widget.controller.getType()}s",),
            leading: Icon(Icons.close),
            onTap: () {
              setState(() {
                this.selectMode = false;
                this.selected.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.appBarText == null) {
      this.appBarText = Text("${widget.title}");
    }

    return  new Scaffold(
      appBar: this.buildAppBar(),
      body: new Center(
          child: IcingaObjectListView(controller: widget.controller, listAll: true, search: this.searchText, selectMode: this.selectMode, selected: this.selected, longClicked: _handleLongClick, reset: reset,)
      ),
      drawer: DrawerMenu(),
      bottomNavigationBar: this.selectMode ? bottomNavBar(context) : null,
    );
  }
}
