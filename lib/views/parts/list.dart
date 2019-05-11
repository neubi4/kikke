import 'package:flutter/material.dart';
import 'package:mobilemon/models/icingaobject.dart';

class ListRow extends StatelessWidget {
  ListRow({Key key, this.iobject, this.clicked}): super(key: key);

  final IcingaObject iobject;
  final ValueChanged<IcingaObject> clicked;

  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: this.iobject.getBackgroundColor(),
        border: Border(
          left: BorderSide(width: 5, color: this.iobject.getBorderColor()),
        ),
      ),
      child: new ListTile(
        title: Text(this.getName()),
        subtitle: Text(this.iobject.getData(this.iobject.outputField)),
        //leading: snapshot.data[index].getIcon(),
        onTap: () {
          print("onTap ${this.iobject.getName()}");
          clicked(this.iobject);
        },
      ),
    );
  }

  String getName() {
    return this.iobject.getName();
  }
}

class ListRowNoHostname extends ListRow {
  ListRowNoHostname({Key key, IcingaObject iobject, ValueChanged<IcingaObject> clicked}): super(key: key, iobject: iobject, clicked: clicked);

  String getName() {
    if (this.iobject.getData('display_name') != null) {
      return this.iobject.getData('display_name');
    }
    return this.iobject.getData('description');
  }
}
