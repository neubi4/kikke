import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kikke/models/icingaobject.dart';
import 'package:kikke/models/service.dart';

class ListRow extends StatelessWidget {
  ListRow({Key key, this.iobject, this.clicked, this.longClicked, this.selected}): super(key: key);

  final IcingaObject iobject;
  final ValueChanged<IcingaObject> clicked;
  final ValueChanged<IcingaObject> longClicked;
  bool selected = false;
  BuildContext context;

  Color getBackgroundColor() {
    return this.iobject.getData('handled') == "0" ? this.iobject.getBackgroundColor(context) : null;
  }

  Widget build(BuildContext context) {
    this.context = context;
    return new Container(
      decoration: new BoxDecoration(
        color: this.getBackgroundColor(),
        border: Border(
          left: BorderSide(width: 5, color: this.iobject.getBorderColor()),
        ),
      ),
      child: new ListTile(
        title: this.getTitle(),
        leading: this.selected ? Icon(Icons.check_box) : null,
        subtitle: Text(this.iobject.getData(this.iobject.outputField)),
        trailing: this.showStatus(),
        onTap: () {
          clicked(this.iobject);
        },
        onLongPress: () {
          if(this.longClicked != null) {
            longClicked(this.iobject);
          }
        },
      ),
    );
  }

  Widget showStatus() {
    if (this.iobject.getData('acknowledged') == "1") {
      return Icon(Icons.check, color: this.iobject.getIconColor(context, 'acknowledged'), size: 17.0);
    } else if (this.iobject.getData('in_downtime') == "1") {
      return Icon(Icons.access_time, color: this.iobject.getIconColor(context, 'in_downtime'), size: 17.0);
    }
  }

  Widget showInstance() {
    return SizedBox(
      width: 50,
      child: AutoSizeText(
        this.iobject.getInstanceName(),
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(color: Colors.black.withOpacity(0.4)),
        maxFontSize: 12,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget getTitle() {
    if (this.iobject is Service) {
      Service service = this.iobject;
      return RichText(
        text: new TextSpan(
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
          ),
          children: <TextSpan>[
            TextSpan(text: service.getDisplayName(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyText1.color)),
            TextSpan(text: " on ", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
            TextSpan(text: service.host.getDisplayName(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyText1.color)),
          ],
        ),
      );
    }
    return Text(this.iobject.getDisplayName());
  }
}

class ListRowNoHostname extends ListRow {
  ListRowNoHostname({Key key, IcingaObject iobject, ValueChanged<IcingaObject> clicked, ValueChanged<IcingaObject> longClicked, bool selected}): super(key: key, iobject: iobject, clicked: clicked, longClicked: longClicked, selected: selected);

  Widget getTitle() {
    if (this.iobject.getData('display_name') != null) {
      return Text(this.iobject.getData('display_name'));
    }
    return Text(this.iobject.getData('description'));
  }

  Widget showInstance() {
    return null;
  }
}
