import 'package:flutter/material.dart';
//import 'package:useful/colors.dart';
class AnnouncementPill extends StatefulWidget {
  AnnouncementPill({Key key, this.announcement, this.widgets}) : super(key: key);
  final Map<String, dynamic> announcement;
  final Map<String, dynamic> widgets;

  _AnnouncementPillState createState() => _AnnouncementPillState();
}

class _AnnouncementPillState extends State<AnnouncementPill> {
  Map<String, dynamic> announcement, widgets;

  void initState() {
    super.initState();
    announcement = widget.announcement;
    widgets = widget.widgets;
  }

  @override
  Widget build(BuildContext context) {
    Row result = new Row(
      children: <Widget>[],
    );
    widgets.forEach((widgetName, widgetType) {
      if (widgetType == 'text' || widgetType == 'time')
        if (announcement[widgetName] != null)
          result.children.add(
            Chip(
              label: Text((announcement[widgetName] == null) ? "" : announcement[widgetName]),
            ),
          );
    });
    return (result == null) ? Container(width: 0.0, height: 0.0) : result;
  }
}