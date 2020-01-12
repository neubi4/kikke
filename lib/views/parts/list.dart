import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobilemon/models/icingaobject.dart';
import 'package:mobilemon/models/service.dart';

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
        title: this.getTitle(),
        subtitle: Text(this.iobject.getData(this.iobject.outputField)),
        trailing: this.showInstance(),
        onTap: () {
          clicked(this.iobject);
        },
      ),
    );
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
            TextSpan(text: service.getDisplayName(), style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: " on "),
            TextSpan(text: service.host.getDisplayName(), style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return Text(this.iobject.getDisplayName());
  }
}

class ListRowNoHostname extends ListRow {
  ListRowNoHostname({Key key, IcingaObject iobject, ValueChanged<IcingaObject> clicked}): super(key: key, iobject: iobject, clicked: clicked);

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
