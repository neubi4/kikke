import 'package:flutter/material.dart';
import 'package:kikke/controller/icingacontroller.dart';
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

  @override
  Widget build(BuildContext context) {
    if (this.appBarText == null) {
      this.appBarText = Text(widget.title);
    }

    return  new Scaffold(
      appBar: this.buildAppBar(),
      body: new Center(
          child: IcingaObjectListView(controller: widget.controller, listAll: true, search: this.searchText,)
      ),
      drawer: DrawerMenu(),
    );
  }
}
